from support import Fixture, run, verify_signature
import base64
import gzip
import json
from urllib.parse import parse_qs, unquote, urlsplit

class Handler(Fixture):

    def route(self, body):
        service = verify_signature(self, body)
        target = self.headers.get('X-Amz-Target', '').split('.')[-1]
        self.server.calls[target] = self.server.calls.get(target, 0) + 1
        assert service == 'iam'
        data = {k: v[0] for k, v in parse_qs(body.decode()).items()}
        action = data['Action']
        assert data['Version'] == '2010-05-08'
        if action == 'CreateRole':
            assert data['RoleName'] == 'role'
            assert json.loads(data['AssumeRolePolicyDocument']) == {'Version': '2012-10-17'}
            value = '<Role><RoleName>role</RoleName><RoleId>id</RoleId><Arn>arn</Arn></Role>'
        elif action == 'DeleteRole':
            assert data['RoleName'] == 'role'
            value = ''
        elif 'Marker' not in data:
            value = '<Policies><member><PolicyName>policy</PolicyName><PolicyId>pid</PolicyId><Arn>arn</Arn><CreateDate>2026-01-02T03:04:05Z</CreateDate><IsAttachable>true</IsAttachable><AttachmentCount>3</AttachmentCount></member></Policies><IsTruncated>true</IsTruncated><Marker>next+/?</Marker>'
        else:
            assert data['Marker'] == 'next+/?'
            value = '<Policies/><IsTruncated>false</IsTruncated>'
        self.reply(200, f'<{action}Response xmlns="https://iam.amazonaws.com/doc/2010-05-08/"><{action}Result>{value}</{action}Result></{action}Response>')
if __name__ == '__main__':
    run(Handler)
