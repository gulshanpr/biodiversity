// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract bioDivAndHer {
    uint public projectCount;
    mapping (uint => bool) public isProjectOrActivityCompleted;
    mapping (uint => project) public projects;
    mapping (uint => Contributor[]) public contributors;
    mapping (uint => uint) private totalContributors;
    mapping (uint => address[]) public volenteers;
    mapping (uint => address[]) public volenteersParticipated;
    mapping (uint => mapping(address => uint)) public credits;
    mapping (uint => string[]) public comments;
    
    mapping (address => uint) public totalCredits;
    mapping (address => uint) public totalParticipations;

    struct project {
        string projectType;
        uint projectID;
        string name;
        string projectDescription;
        string location;
        address campaginCreator;
        bool status;
        uint totalFundGoalNeeded;
        uint totalFundCurrentStatus;
    }

    struct Volenteer {
        address registeredContributors;
    }

    struct Contributor {
        address contributor;
        uint amount;
        uint timestamp;
    }

    // Create a new project or activity
    function createProject(string memory _projectType, string memory _name, string memory _projectDescription, string memory _location, uint _totalFundGoalNeeded) public {
        projectCount++;
        projects[projectCount] = project({
            projectType: _projectType,
            projectID: projectCount,
            name: _name,
            projectDescription: _projectDescription,
            location: _location,
            campaginCreator: msg.sender,
            status: true,
            totalFundGoalNeeded: _totalFundGoalNeeded,
            totalFundCurrentStatus: 0
        });
        isProjectOrActivityCompleted[projectCount] = false;
    }

    // Fund the campaign or program
    function contribute(uint _projectID, bool _wantToVolenteer) public payable {
        project storage projectInstance = projects[_projectID];
        require(projectInstance.status, "Project is not active");
        projectInstance.totalFundCurrentStatus += msg.value;
        contributors[_projectID].push(Contributor({
            contributor: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        }));

        if (_wantToVolenteer) {
            volenteers[_projectID].push(msg.sender);
        }
    }

    // Additional Comments in a Campaign
    function commentsInACampaginOrActivity(uint _projectID, string memory _comment) public {
        project storage projectInstance = projects[_projectID];
        require(projectInstance.status, "Project is not active");
        require(msg.sender == projectInstance.campaginCreator, "Only campaign creator can add comments");
        comments[_projectID].push(_comment);
    }

    // Participant interested in participating
    function participateInProjectOrAcitvity(uint _projectID) public {
        project storage projectInstance = projects[_projectID];
        require(projectInstance.status, "Project is not active");
        volenteers[_projectID].push(msg.sender);
    }

    // Campaign owner will mark who has participated
    function markParticipate(uint _projectID, address _person) public {
        project storage projectInstance = projects[_projectID];
        require(projectInstance.status, "Project is not active");
        require(msg.sender == projectInstance.campaginCreator, "Only campaignCreator can mark people");
        volenteersParticipated[_projectID].push(_person);
    }

    // Check if a person has participated
    function isVolenteerParticipated(uint _projectID, address _participant) public view returns (bool) {
        address[] storage participants = volenteersParticipated[_projectID];
        for (uint i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                return true;
            }
        }
        return false;
    }

    // Close the project and issue credits to participants
    function closeProjectOrActivity(uint _projectID, uint _totalCreditAlloted) public {
        project storage projectInstance = projects[_projectID];
        require(projectInstance.status, "Project is not active");
        require(msg.sender == projectInstance.campaginCreator, "You are not the owner of this campaign");
        projectInstance.status = false;
        isProjectOrActivityCompleted[_projectID] = true;

        // Issue credits to participants
        for (uint i = 0; i < volenteersParticipated[_projectID].length; i++) {
            address participant = volenteersParticipated[_projectID][i];
            credits[_projectID][participant] += _totalCreditAlloted;
            totalCredits[participant] += _totalCreditAlloted;
            totalParticipations[participant]++;
        }
    }

    // Total Contributors in a project
    function getTotalContributors(uint _projectID) public view returns (uint) {
        return contributors[_projectID].length;
    }

    // Total credit of a contributor in a project
    function getCreditBalance(uint _projectID, address _participant) public view returns (uint) {
        return credits[_projectID][_participant];
    }

    // Total credits of a user across all projects
    function getTotalCredits(address _user) public view returns (uint) {
        return totalCredits[_user];
    }

    // Total number of projects a user has participated in
    function getTotalParticipations(address _user) public view returns (uint) {
        return totalParticipations[_user];
    }

    // Withdraw funds from a completed project
    function withdrawFunds(uint _projectID) public {
        project storage projectInstance = projects[_projectID];
        require(!projectInstance.status, "Project is still active");
        require(isProjectOrActivityCompleted[_projectID], "Project is not completed yet");
        require(msg.sender == projectInstance.campaginCreator, "Only the project creator can withdraw funds");

        uint amount = projectInstance.totalFundCurrentStatus;
        projectInstance.totalFundCurrentStatus = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Total funds in a project
    function getTotalFunds(uint _projectID) public view returns (uint) {
        project storage projectInstance = projects[_projectID];
        return projectInstance.totalFundCurrentStatus;
    }

    /**

    Pending work
    - use user total credit to buy them or give discount on marketplace
    - code for marketplace
    - nft contract

    **/
}
