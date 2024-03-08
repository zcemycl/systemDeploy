import { SageMakerClient, CreatePresignedDomainUrlCommand, ListUserProfilesCommand, CreateUserProfileCommand } from "@aws-sdk/client-sagemaker";

const config = {
    region: "eu-west-2"
};
const client = new SageMakerClient(config);
const domainId = "d-rfglyw8eh7uj";
const username = "leo-leung-abc";
const sgid = "sg-0a82ee821307349b4";
const exe_role = "arn:aws:iam::322725876573:role/leo_sagemaker_role";
const defaultCheckUserArgs = {
    MaxResults: 1,
    DomainIdEquals: domainId,
}

const defaultUserSettings = {
    ExecutionRole: exe_role,
    SecurityGroups: [sgid],
    SharingSettings: {
        NotebookOutputOption: "Allowed"
    },
    JupyterServerAppSettings: {
        DefaultResourceSpec: {
            SageMakerImageArn: "arn:aws:sagemaker:eu-west-2:712779665605:image/jupyter-server-3",
            InstanceType: "system"
        }
    },
    RStudioServerProAppSettings:{
        AccessStatus: "DISABLED"
    },
    CanvasAppSettings: {
        TimeSeriesForecastingSettings: {
            Status: "DISABLED"
        },
        ModelRegisterSettings: {
            Status: "DISABLED"
        }
    }
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
    console.log({Message: "None"});
    const command_create_user = new CreateUserProfileCommand(
        {
            DomainId: domainId,
            UserProfileName: username,
            UserSettings: defaultUserSettings
        }
    )
    await client.send(command_create_user);
}
const command = new CreatePresignedDomainUrlCommand(input);
const response = await client.send(command);
console.log(response);
