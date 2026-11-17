# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

package require pure-tcl-aws-core 1.0.0
namespace eval ::aws::iam {namespace path ::aws::core}
::aws::core::register iam {create_role delete_role list_policies}

# Create a role and return its name, ID and ARN.
proc ::aws::iam::_create_role {client name policy} {
    set doc [query $client CreateRole 2010-05-08 [list RoleName $name AssumeRolePolicyDocument $policy]]
    try {
        set role [lindex [nodes [$doc documentElement] CreateRoleResult/Role] 0]
        return [dict create role_name [xget $role RoleName] role_id [xget $role RoleId] arn [xget $role Arn]]
    } finally {$doc delete}
}

# Delete a role after its policies and instance profiles have been detached.
proc ::aws::iam::_delete_role {client name} {
    set doc [query $client DeleteRole 2010-05-08 [list RoleName $name]]
    $doc delete
    return
}

# Format AWS timestamps using the original binding's UTC date format.
proc ::aws::iam::date {value} {
    if {$value eq {}} {return {}}
    clock format [clock scan $value -gmt 1] -gmt 1 -format %Y-%m-%d
}

# Follow policy pagination and preserve the legacy policy dictionaries.
proc ::aws::iam::_list_policies {client} {
    set fields {}; set out {}; set seen {}
    while {1} {
        set doc [query $client ListPolicies 2010-05-08 $fields 1]
        try {
            set root [lindex [nodes [$doc documentElement] ListPoliciesResult] 0]
            foreach policy [nodes $root Policies/member] {
                set value {}
                foreach {target source} {policy_name PolicyName policy_id PolicyId arn Arn description Description create_date CreateDate update_date UpdateDate attachment_count AttachmentCount is_attachable IsAttachable path Path default_version_id DefaultVersionId} {
                    set v [xget $policy $source]
                    if {$target in {create_date update_date}} {set v [date $v]}
                    if {$target eq "attachment_count" && $v eq {}} {set v 0}
                    if {$target eq "is_attachable"} {set v [boolean [xget $policy $source false]]}
                    dict set value $target $v
                }
                lappend out $value
            }
            if {![boolean [xget $root IsTruncated false]]} {return $out}
            set marker [xget $root Marker]
            if {$marker eq {}} {error "truncated IAM response is missing a marker"}
            next seen $marker
            set fields [list Marker $marker]
        } finally {$doc delete}
    }
}
package provide pure-tcl-aws-iam 0.1.1
package provide awsiam 1.0.19
