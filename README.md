# pure-tcl-aws-iam

AWS IAM client implemented in Tcl 9.1. Its only package dependency is
[`pure-tcl-aws-core`](https://github.com/jerily/pure-tcl-aws-core), which supplies
HTTP, JSON, XML, credentials and signing. No AWS C++ SDK is required.

```tcl
package require pure-tcl-aws-iam 1.0.0
set client [::aws::iam::create {region us-east-1}]
try {
    puts [$client list_policies]
} finally {
    $client destroy
}
```

`package require awsiam 1.0.19` is also supported. Use one implementation
of the `awsiam` package per interpreter. Existing namespace commands
(`::aws::iam::method $client ...`) and client methods share the same behavior.
Client destruction returns an empty result. Unknown methods and invalid arguments
raise Tcl errors. See the core README for credentials, configuration and retries.

## Methods

| Method | Arguments after the client handle |
| --- | --- |
| `create_role` | `name policy` |
| `delete_role` | `name` |
| `list_policies` | — |

## Behavior

The three existing IAM operations use the Query API. Role and policy dictionaries retain the existing lowercase field names. Policy pagination is automatic and dates use `YYYY-MM-DD` UTC.

## Install and examples

Install the core and its dependencies first, then run:

```sh
make install PREFIX=/your/prefix
```

The release recipe declares examples with `file` entries. After registry installation:

```sh
ttrek run -package pure-tcl-aws-iam -script example-list-policies
```

`./run-example.sh --help` lists arguments. Set AWS credentials and `AWS_REGION`
or `AWS_DEFAULT_REGION` before running AWS examples. Examples read resources or sign URLs.

## Tests

With Tcl 9.1 and the dependencies on `TCLLIBPATH`:

```sh
make test TCLSH=tclsh9.1
```

Python 3 supplies local HTTP fixtures. Tests use fake credentials and do not
contact AWS. They check requests, result formats, and error handling.

## Install with ttrek

If you do not have the ttrek client, get it from [ttrek.sh](https://ttrek.sh).
Then install the package:

```sh
ttrek install pure-tcl-aws-iam
```
