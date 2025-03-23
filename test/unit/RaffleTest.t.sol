// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Raffle} from "src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "script/HelperConfig.s.sol";

contract RaffleTest is CodeConstants, Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    // Events
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);
        // Act / Asser
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
        // Asset
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        // Asset
        address playerRecorded = raffle.getPlayers(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        // Asset
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    /*
    Check Upkeep
    */
    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfRaffleIsNotOpen() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // Assert
        assert(!upkeepNeeded);
    }

    // Challenge
    /*
Uncovered for src/Raffle.sol:
- Branch (branch: 2, path: 0) (location: source ID 39, lines 133..140, bytes 4349..4531, hits: 0)
- Line (location: source ID 39, lines 134..139, bytes 4363..4520, hits: 0)
- Statement (location: source ID 39, lines 134..139, bytes 4363..4520, hits: 0)
- Line (location: source ID 39, lines 161..185, bytes 5345..6107, hits: 0)
- Function "fulfillRandomWords" (location: source ID 39, lines 161..185, bytes 5345..6107, hits: 0)
- Line (location: source ID 39, lines 169..170, bytes 5546..5603, hits: 0)
- Statement (location: source ID 39, lines 169..170, bytes 5546..5603, hits: 0)
- Statement (location: source ID 39, lines 169..170, bytes 5570..5603, hits: 0)
- Line (location: source ID 39, lines 170..171, bytes 5613..5668, hits: 0)
- Statement (location: source ID 39, lines 170..171, bytes 5613..5668, hits: 0)
- Line (location: source ID 39, lines 171..172, bytes 5678..5707, hits: 0)
- Statement (location: source ID 39, lines 171..172, bytes 5678..5707, hits: 0)
- Line (location: source ID 39, lines 172..173, bytes 5717..5749, hits: 0)
- Statement (location: source ID 39, lines 172..173, bytes 5717..5749, hits: 0)
- Line (location: source ID 39, lines 174..175, bytes 5760..5796, hits: 0)
- Statement (location: source ID 39, lines 174..175, bytes 5760..5796, hits: 0)
- Line (location: source ID 39, lines 176..177, bytes 5807..5840, hits: 0)
- Statement (location: source ID 39, lines 176..177, bytes 5807..5840, hits: 0)
- Line (location: source ID 39, lines 177..178, bytes 5850..5883, hits: 0)
- Statement (location: source ID 39, lines 177..178, bytes 5850..5883, hits: 0)
- Line (location: source ID 39, lines 180..181, bytes 5951..6021, hits: 0)
- Statement (location: source ID 39, lines 180..181, bytes 5951..6021, hits: 0)
- Statement (location: source ID 39, lines 180..181, bytes 5970..6021, hits: 0)
- Line (location: source ID 39, lines 181..182, bytes 6035..6043, hits: 0)
- Statement (location: source ID 39, lines 181..182, bytes 6035..6043, hits: 0)
- Branch (branch: 3, path: 0) (location: source ID 39, lines 181..184, bytes 6045..6101, hits: 0)
- Line (location: source ID 39, lines 182..183, bytes 6059..6090, hits: 0)
- Statement (location: source ID 39, lines 182..183, bytes 6059..6090, hits: 0)
- Line (location: source ID 39, lines 187..190, bytes 6141..6234, hits: 0)
- Function "getEntranceFee" (location: source ID 39, lines 187..190, bytes 6141..6234, hits: 0)
- Line (location: source ID 39, lines 188..189, bytes 6207..6227, hits: 0)
- Statement (location: source ID 39, lines 188..189, bytes 6207..6227, hits: 0)

    */

    /*
    Perform Upkeep
    */
    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue()
        public
        raffleEntered
    {
        // Act
        raffle.performUpkeep("");
    }

    function testPerformUpkeepReversIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance = currentBalance + entranceFee;
        numPlayers = 1;

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                rState
            )
        );
        raffle.performUpkeep("");
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    // what if we need to get data from emitted events in this case?
    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEntered
    {
        // Act
        vm.recordLogs();
        raffle.performUpkeep(""); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        // requestId = raffle.getLastRequestId();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1); // 0 = open, 1 = calculating
    }

    ///////////////////////////
    // fulfill Random Words
    ///////////////////////////

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 randomRequestId
    ) public raffleEntered skipFork {
        // Arrange / Act /assert
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            randomRequestId,
            address(raffle)
        );
    }

    function testFulfillrandomWordsPicksWinnerResetsAndSendsMoney()
        public
        raffleEntered
        skipFork
    {
        // Arrange
        uint256 additionalEntrants = 3; // 4 total
        uint256 startingIndex = 1;

        for (
            uint256 i = startingIndex;
            i < startingIndex + additionalEntrants;
            i++
        ) {
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }

        uint256 startingTimeStamp = raffle.getLastTimeStamp();

        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );
    }
}
