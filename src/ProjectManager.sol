// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

error ProjectManager_OnlyOwnerCanCompleteProject();

contract ProjectManager {
    enum ProjectState {
        FUNDING,
        COMPLETED
    }

    struct Project {
        uint256 id;
        address owner;
        uint256 requiredAmount;
        uint256 funding;
        ProjectState state;
    }

    uint256 private projectId;
    Project[] private projects;
    mapping(address backer => mapping(uint256 projectId => uint256 funding)) private fundings;

    /**
     * @dev Creates a project that backers can fund.
     * @dev Start with native token.
     */
    function createProject(uint256 _requiredAmount) external {
        ++projectId;
        Project memory project = Project({
            id: projectId,
            owner: msg.sender,
            requiredAmount: _requiredAmount,
            funding: 0,
            state: ProjectState.FUNDING
        });

        projects.push(project);
    }

    function fundProject(uint256 _projectId) external payable {
        projects[_projectId - 1].funding += msg.value;
        fundings[msg.sender][_projectId] += msg.value;
    }

    function withdrawProjectFunding(uint256 _projectId) external {
        uint256 backerFunding = fundings[msg.sender][_projectId];

        projects[_projectId - 1].funding -= backerFunding;
        fundings[msg.sender][_projectId] = 0;

        (bool success,) = payable(msg.sender).call{value: backerFunding}("");
        require(success);
    }

    function completeProject(uint256 _projectId) external {
        Project memory project = projects[_projectId - 1];

        if (project.owner != msg.sender) revert ProjectManager_OnlyOwnerCanCompleteProject();

        if (project.requiredAmount >= project.funding) {
            projects[_projectId - 1].state = ProjectState.COMPLETED;
        }

        (bool success,) = payable(project.owner).call{value: project.funding}("");
        require(success);
    }
}
