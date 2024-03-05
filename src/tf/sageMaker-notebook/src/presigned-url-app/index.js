import { SageMakerClient, CreatePresignedDomainUrlCommand } from "@aws-sdk/client-sagemaker";

const config = {
    region: "eu-west-2"
};
const client = new SageMakerClient(config);
const input = { // CreatePresignedDomainUrlRequest
    DomainId: "d-6rlatnnd0mat", // required
    UserProfileName: "leo-leung", // required
    ExpiresInSeconds: 20,
};

const command = new CreatePresignedDomainUrlCommand(input);
const response = await client.send(command);
console.log(response);
