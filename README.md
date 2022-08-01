# ☁️  marcellodesales/aws-sam-server-docker

Dockerized version of AWS sam api server so you can test your serverless code before pushing to AWS Lambda service!!!

# 🤷 Why

We use CDK to develop the lambda in multiple languages (Java, Nodejs, Golang, Python) so it's important to keep this
as simple as possible, reusing the CDK templates based on the current code. Avoid multiple round-trips to AWS Console.

# ⬇️  Setup

* Install latest version of docker engine.
* Make sure `docker-compose` or `docker compose` commands work.

# 🔧 Config

> **NOTE**: Make sure to follow the steps from Serverless CDK guids
> * https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-cdk-getting-started.html

1. You must discover your cdk environments
2. Then generate the templates from all your environments
3. Convert the environment template to the YAML template format
4. Start the dockerized SAM server with the YAML template
5. Copy our `docker-compose.yaml` to the root of your CDK project.
6. Profit! Test your lambda functions without pushing to AWS Lambda!

## 🙌 Discover environments of your CDK project
 
```console
$ cdk synth --no-staging

===> Creating or updating stack SupercashWebPlatformStackProd...
===> Loading stage "prod" of/for stack SupercashWebPlatformStackProd
  --> Logical id: APIDomainName-prod
  --> Logical id: AdminDomainName-prod
  --> Logical id: HTTPApiGatewayIntegration
  --> Logical id: Route53APIHostName-prod
  --> Logical id: APIAuthenticationService-prod
  --> Logical id: UserPool-prod
  --> Logical id: UserPoolAppClient-prod
  --> Logical id: AuthentificationServiceAdminsGroup-prod
  --> Logical id: AuthentificationServiceAdminUsersleandro@supercash.io-prod
  --> Logical id: AuthentificationServiceAdminUsersmarcello@supercash.io-prod
  --> Logical id: AuthentificationServiceCognitoTriggersFunction-prod
  --> Logical id: AuthenticationServiceBucket-prod
  --> Logical id: AuthentificationServiceFunction-prod
  --> Logical id: AuthentificationServiceFunctionIntegration-prod
  --> Logical id: APIParkinglotService-prod
  --> Logical id: ParkinglotServiceFunction-prod
  --> Logical id: ParkinglotServiceFunctionIntegration-prod
===> Creating or updating stack SupercashWebPlatformStackDev...
===> Loading stage "dev" of/for stack SupercashWebPlatformStackDev
  --> Logical id: APIDomainName-dev
  --> Logical id: AdminDomainName-dev
  --> Logical id: HTTPApiGatewayIntegration
  --> Logical id: Route53APIHostName-dev
  --> Logical id: APIAuthenticationService-dev
  --> Logical id: UserPool-dev
  --> Logical id: UserPoolAppClient-dev
  --> Logical id: AuthentificationServiceAdminsGroup-dev
  --> Logical id: AuthentificationServiceAdminUsersleandro@supercash.io-dev
  --> Logical id: AuthentificationServiceAdminUsersmarcello@supercash.io-dev
  --> Logical id: AuthentificationServiceCognitoTriggersFunction-dev
  --> Logical id: AuthenticationServiceBucket-dev
  --> Logical id: AuthentificationServiceFunction-dev
  --> Logical id: AuthentificationServiceFunctionIntegration-dev
  --> Logical id: APIParkinglotService-dev
  --> Logical id: ParkinglotServiceFunction-dev
  --> Logical id: ParkinglotServiceFunctionIntegration-dev
Successfully synthesized to /Users/marcellodesales/dev-backup-64b/dev/gitlab.com/supercash/platform/services/parkinglot-service-serverless-cdk/cdk.out
Supply a stack id (SupercashWebPlatformStackDev, SupercashWebPlatformStackProd) to display its template.
```

## 👷 Generate the templates for SAM

> **NOTE**: Here I'm choosing one of the stack ids from the output logs before
> * The output of the command creates a directory `./cdk.outs`

```console
$ cdk synth --no-staging SupercashWebPlatformStackDev

===> Creating or updating stack SupercashWebPlatformStackProd...
===> Loading stage "prod" of/for stack SupercashWebPlatformStackProd
  --> Logical id: APIDomainName-prod
  --> Logical id: AdminDomainName-prod
  --> Logical id: HTTPApiGatewayIntegration
  --> Logical id: Route53APIHostName-prod
  --> Logical id: APIAuthenticationService-prod
  --> Logical id: UserPool-prod
  --> Logical id: UserPoolAppClient-prod
  --> Logical id: AuthentificationServiceAdminsGroup-prod
  --> Logical id: AuthentificationServiceAdminUsersleandro@supercash.io-prod
  --> Logical id: AuthentificationServiceAdminUsersmarcello@supercash.io-prod
  --> Logical id: AuthentificationServiceCognitoTriggersFunction-prod
  --> Logical id: AuthenticationServiceBucket-prod
  --> Logical id: AuthentificationServiceFunction-prod
  --> Logical id: AuthentificationServiceFunctionIntegration-prod
  --> Logical id: APIParkinglotService-prod
  --> Logical id: ParkinglotServiceFunction-prod
  --> Logical id: ParkinglotServiceFunctionIntegration-prod
===> Creating or updating stack SupercashWebPlatformStackDev...
===> Loading stage "dev" of/for stack SupercashWebPlatformStackDev
  --> Logical id: APIDomainName-dev
  --> Logical id: AdminDomainName-dev
  --> Logical id: HTTPApiGatewayIntegration
  --> Logical id: Route53APIHostName-dev
  --> Logical id: APIAuthenticationService-dev
  --> Logical id: UserPool-dev
  --> Logical id: UserPoolAppClient-dev
  --> Logical id: AuthentificationServiceAdminsGroup-dev
  --> Logical id: AuthentificationServiceAdminUsersleandro@supercash.io-dev
  --> Logical id: AuthentificationServiceAdminUsersmarcello@supercash.io-dev
  --> Logical id: AuthentificationServiceCognitoTriggersFunction-dev
  --> Logical id: AuthenticationServiceBucket-dev
  --> Logical id: AuthentificationServiceFunction-dev
  --> Logical id: AuthentificationServiceFunctionIntegration-dev
  --> Logical id: APIParkinglotService-dev
  --> Logical id: ParkinglotServiceFunction-dev
  --> Logical id: ParkinglotServiceFunctionIntegration-dev
```
```yaml
Resources:
  SupercashCrossRegionCertificateCertificateRequestorFunctionServiceRoleC2CBA1EF:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Action: sts:AssumeRole
            Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
        Version: "2012-10-17"
...
...
```

* This results in the creation of the dir

```console
$ tree cdk.out -L 1
cdk.out
├── SupercashWebPlatformStackDev.assets.json
├── SupercashWebPlatformStackDev.template.json
├── SupercashWebPlatformStackProd.assets.json
├── SupercashWebPlatformStackProd.template.json
├── cdk.out
├── manifest.json
└── tree.json
```

## 🔨 Create a template.yaml based on one of the templates

> **NOTE**: `.yaml` files are a subset of `.json` and, therefore, can be used as a hack for the creation of the template.yaml required by SAM.
> * After this step, your are ready to run!
```console
cp cdk.out/SupercashWebPlatformStackDev.template.json template.yaml
```

## ✂️ Copy the docker-compose.yaml to your CDK project root's dir

> **NOTE**: Make sure the file is located in the root dir
> * The version of the docker image used is latest.

```yaml
version: '3.9'

# Setup a provide network for local deployments of aws services
networks:
  backend:
    name: aws_backend
    driver: bridge

services:

  aws-sam-api-server:
    # Choose a release version or a SHA version, latest is tested
    image: marcellodesales/aws-sam-server:latest

    # A container will run in a dir with the same name as current dir
    working_dir: $PWD

    volumes:
      # The volumes for the current dir is mounted
      - $PWD:$PWD

      # Needed so a docker container can be run from inside a docker container
      - /var/run/docker.sock:/var/run/docker.sock 

      # The settings to your aws if needed
      - ~/.aws/:/root/.aws:ro

    networks:
      - "backend"

    ports:
      # SAM API server runs on port 3000
      - "3000:3000"

    environment:
      # Just don't send telemetry data to AWS...
      SAM_CLI_TELEMETRY: false

      # The docker network created
      DOCKER_NETWORK: aws_backend
```

# 🏃 Run

```console
$ docker-compose up
[+] Running 1/1
 ⠿ Container supercash-aws-sam  Recreated                                                                                                        0.2s
Attaching to supercash-aws-sam
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/auth [POST, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/auth/forgot-password [POST, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/auth/confirm-forgot-password [POST, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/auth/confirm-sign-up [GET, POST, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/auth/resend-confirmation-code [POST, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/users [GET, POST, PUT, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/users/{id} [DELETE, GET, PUT, OPTIONS]
supercash-aws-sam  | Mounting AuthentificationServiceFunction-dev at http://0.0.0.0:3000/v1/users/status/{id} [GET, POST, OPTIONS]
supercash-aws-sam  | Mounting ParkinglotServiceFunction-dev at http://0.0.0.0:3000/v1/parkinglots/tickets [GET, OPTIONS]
supercash-aws-sam  | Mounting ParkinglotServiceFunction-dev at http://0.0.0.0:3000/v1/parkinglots/tickets/{id} [GET, OPTIONS]
supercash-aws-sam  | Mounting ParkinglotServiceFunction-dev at http://0.0.0.0:3000/v1/parkinglots/tickets/{id}/pay [POST, OPTIONS]
supercash-aws-sam  | You can now browse to the above endpoints to invoke your functions. You do not need to restart/reload SAM CLI while working on your functions, changes will be reflected instantly/automatically. You only need to restart SAM CLI if you update your AWS SAM template
supercash-aws-sam  | 2022-08-01 09:02:42  * Running on all addresses.
supercash-aws-sam  |    WARNING: This is a development server. Do not use it in a production deployment.
supercash-aws-sam  | 2022-08-01 09:02:42  * Running on http://172.23.0.2:3000/ (Press CTRL+C to quit)
```

# ✅ Test

* Now, you can make requests to one of the endpoints listed and test the local code...

## 🔊 CURL Client Logs

* Invoking the step function...

```console
$ curl -i http://0.0.0.0:3000/v1/parkinglots/tickets/2030340492\?scanned\=false
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 13
Server: Werkzeug/2.0.0 Python/3.9.5
Date: Mon, 01 Aug 2022 09:02:46 GMT

ticket status%
```

# 🔊 SAM Server Logs

* The output of the terminal of the SAM server will show the interaction and running the lambda selected:

```console
...
...
supercash-aws-sam  | 2022-08-01 09:02:42  * Running on http://172.23.0.2:3000/ (Press CTRL+C to quit)
supercash-aws-sam  | Invoking parkinglots.main (nodejs14.x)
supercash-aws-sam  | Skip pulling image and use local one: public.ecr.aws/sam/emulation-nodejs14.x:rapid-1.53.0-x86_64.
supercash-aws-sam  |
supercash-aws-sam  | Mounting /Users/marcellodesales/dev-backup-64b/dev/gitlab.com/supercash/platform/services/parkinglot-service-serverless-cdk/resources/v1/Parkinglot as /var/task:ro,delegated inside runtime container
supercash-aws-sam  | START RequestId: 751ad9f3-0d68-4c67-87bd-82bac07d719a Version: $LATEST
supercash-aws-sam  | 2022-08-01T09:02:45.744Z	751ad9f3-0d68-4c67-87bd-82bac07d719a	INFO	event: {"version":"2.0","routeKey":"GET /v1/parkinglots/tickets/{id}","rawPath":"/v1/parkinglots/tickets/2030340492","rawQueryString":"scanned=false","cookies":[],"headers":{"Host":"0.0.0.0:3000","User-Agent":"curl/7.79.1","Accept":"*/*","X-Forwarded-Proto":"http","X-Forwarded-Port":"3000"},"requestContext":{"accountId":"123456789012","apiId":"1234567890","http":{"method":"GET","path":"/v1/parkinglots/tickets/2030340492","protocol":"HTTP/1.1","sourceIp":"172.23.0.1","userAgent":"Custom User Agent String"},"requestId":"5eb07add-83e8-49ef-a053-cdd1ea9eaf1d","routeKey":"GET /v1/parkinglots/tickets/{id}","stage":"$default","time":"01/Aug/2022:09:02:41 +0000","timeEpoch":1659344561,"domainName":"localhost","domainPrefix":"localhost"},"body":"","pathParameters":{"id":"2030340492"},"stageVariables":null,"isBase64Encoded":false,"queryStringParameters":{"scanned":"false"}}
supercash-aws-sam  | END RequestId: 751ad9f3-0d68-4c67-87bd-82bac07d719a
supercash-aws-sam  | REPORT RequestId: 751ad9f3-0d68-4c67-87bd-82bac07d719a	Init Duration: 1.00 ms	Duration: 408.74 ms	Billed Duration: 409 ms	Memory Size: 128 MB	Max Memory Used: 128 MB
supercash-aws-sam  | No Content-Type given. Defaulting to 'application/json'.
supercash-aws-sam  | 2022-08-01 09:02:46 172.23.0.1 - - [01/Aug/2022 09:02:46] "GET /v1/parkinglots/tickets/2030340492?scanned=false HTTP/1.1" 200 -
```

# 🛠️ Extending

* Fork the repo and update the Dockerfile for any additional things in the server
* You can install anything else required by the server.

