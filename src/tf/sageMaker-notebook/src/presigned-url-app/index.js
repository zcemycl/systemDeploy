import { SageMakerClient, CreatePresignedDomainUrlCommand, ListUserProfilesCommand } from "@aws-sdk/client-sagemaker";

const config = {
    region: "eu-west-2"
};
const client = new SageMakerClient(config);
const domainId = "d-chows9qomj8t";
const username = "test-user"
const defaultCheckUserArgs = {
    MaxResults: 1,
    DomainIdEquals: domainId,
}
const input = { // CreatePresignedDomainUrlRequest
    DomainId: domainId, // required
    UserProfileName: username, // required
    ExpiresInSeconds: 20,
};

const checkUserList = (userinfolist, username) => {
    let isFound = false;
    for (let userinfo of userinfolist) {
        if ( userinfo["UserProfileName"] === username){
            isFound = true;
            break;
        }
    }
    return isFound;
}

const checkUser = async (username) => {
    let checkUserArg = {...defaultCheckUserArgs,
        UserProfileNameContains: username};
    let command = new ListUserProfilesCommand(checkUserArg);
    let response = await client.send(command);
    let isFound = checkUserList(response["UserProfiles"], username);
    while ((!isFound) && ("NextToken" in response)) {
        checkUserArg = {...checkUserArg, NextToken: response["NextToken"]};
        command = new ListUserProfilesCommand(checkUserArg);
        response = await client.send(command);
        isFound = checkUserList(response["UserProfiles"], username);
    }
    return isFound;
}

const isFound = await checkUser(username);
if (!isFound) {
    console.log({Message: "None"})
} else {
    const command = new CreatePresignedDomainUrlCommand(input);
    const response = await client.send(command);
    console.log(response);
}
