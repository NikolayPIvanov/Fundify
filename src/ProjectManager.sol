// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

error ProjectManager_OnlyCreatorCanCompleteProject();
error ProjectManager_ProjectNotInFundingState(uint256 projectId);
error ProjectManager_ProjectNotFunded(uint256 projectId);

contract ProjectManager {
    enum ProjectState {
        FUNDING,
        FUNDED
    }

    struct Project {
        uint256 id;
        address creator;
        uint256 requiredAmount;
        uint256 funding;
        ProjectState state;
    }

    uint256 private projectId;
    Project[] private projects;
    mapping(address backer => mapping(uint256 projectId => uint256 funding)) private fundings;

    event ProjectCreated(uint256 indexed projectId);
    event ProjectFunded(uint256 indexed projectId);
    event ProjectCompleted(uint256 indexed projectId);
    event Contributed(address indexed backer, uint256 contribution);
    event ContributionWithdrawn(address indexed backer, uint256 contribution);

    /**
     * @dev Creates a project that backers can fund.
     * @dev Start with native token.
     */
    function createProject(uint256 _requiredAmount) external {
        ++projectId;
        Project memory project = Project({
            id: projectId,
            creator: msg.sender,
            requiredAmount: _requiredAmount,
            funding: 0,
            state: ProjectState.FUNDING
        });

        projects.push(project);

        emit ProjectCreated(projectId);
    }

    function contribute(uint256 _projectId) external payable {
        Project memory project = projects[_projectId - 1];

        // Allow funding when State is FUNDING
        if (project.state != ProjectState.FUNDING) {
            revert ProjectManager_ProjectNotInFundingState(_projectId);
        }

        if (project.funding + msg.value >= project.requiredAmount) {
            projects[_projectId - 1].state = ProjectState.FUNDED;

            emit ProjectFunded(projectId);
        }

        projects[_projectId - 1].funding += msg.value;
        fundings[msg.sender][_projectId] += msg.value;

        emit Contributed(msg.sender, msg.value);
    }

    function withdraw(uint256 _projectId) external {
        Project memory project = projects[_projectId - 1];

        if (project.state != ProjectState.FUNDING) {
            revert ProjectManager_ProjectNotInFundingState(_projectId);
        }

        uint256 backerFunding = fundings[msg.sender][_projectId];

        if (backerFunding > 0) {
            projects[_projectId - 1].funding -= backerFunding;
            fundings[msg.sender][_projectId] = 0;

            emit ContributionWithdrawn(msg.sender, backerFunding);

            (bool success,) = payable(msg.sender).call{value: backerFunding}("");
            require(success);
        }
    }

    function completeProject(uint256 _projectId) external {
        Project memory project = projects[_projectId - 1];

        if (project.state != ProjectState.FUNDED) revert ProjectManager_ProjectNotFunded(_projectId);
        if (project.creator != msg.sender) revert ProjectManager_OnlyCreatorCanCompleteProject();

        emit ProjectCompleted(_projectId);

        (bool success,) = payable(project.creator).call{value: project.funding}("");
        require(success);
    }
}
