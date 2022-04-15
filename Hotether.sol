pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract OwnedContract {
    address public owner;
    address public cleaner;

    event transfer(address Customer, uint amount);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCleaner{
        _;
        require(msg.sender == cleaner);
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract BookingContract is OwnedContract {
    string public HotelName;
    string public Location;
    uint public numRooms;
    status public RoomStatus;

    enum status {
        available,
        occupied,
        dirty,
        clean
    }

    struct Room {
        uint capacity;
        uint numOccupants;
        bool occupied;
        status condition;
        address occupier;
    }

    modifier costs (uint _amount) {
        require(msg.value >= _amount, "Not enough Ether provided");
        _;
    }


    //Public so that people can see which rooms are available without seeing identities
    Room[] public rooms;
    function getRoom() public view returns (Room[] memory ){
        return rooms;
    }


    constructor() public {
        HotelName = "The Louis";
        Location = "Montreal";
        numRooms = 0;

    }

    function addRoom (uint roomCapacity) onlyOwner payable public {
        numRooms += 1;
        rooms.push(Room({
            capacity: roomCapacity,
            numOccupants: 0,
            occupied: false,
            condition: status.available,
            occupier: address(0)
        }));
    }

    function checkin(address occupant, uint roomNumber) public payable {
        require(msg.value >= 1 ether, "Not enough Ether provided!");
        Room storage currentRoom = rooms[roomNumber];
        currentRoom.occupier = occupant;
        ChangeRoomOccupancyStatus(status.available, roomNumber);
        emit transfer(msg.sender, 1 ether);
        
    }

    function ChangeRoomOccupancyStatus (status occupancyStatus, uint roomNumber) public {
        Room storage currentRoom = rooms[roomNumber];
        if (currentRoom.condition == status.occupied) {
            require (occupancyStatus == status.available);
            currentRoom.numOccupants = 0;
            currentRoom.occupied = false;
        }
        else {
            require (occupancyStatus == status.occupied);
            currentRoom.numOccupants = currentRoom.capacity;
            currentRoom.occupied = true;
        }
        currentRoom.condition = occupancyStatus;
    }
}

contract Hostel is BookingContract {

    function ChangeRoomOccupancyStatus (status occupancyStatus, uint roomNumber) public {
        Room storage currentRoom = rooms[roomNumber];
        if (currentRoom.condition == status.occupied) {
            require (occupancyStatus == status.available);
        }
        else {
            require (occupancyStatus == status.occupied);
            currentRoom.occupied = true;
        }
        currentRoom.condition = occupancyStatus;
    }

    function addOccupantToRoom (uint roomNumber) public {
        Room storage currentRoom =rooms[roomNumber];
        require (currentRoom.numOccupants < currentRoom.capacity);
        if (currentRoom.numOccupants == 0) {
            ChangeRoomOccupancyStatus (status.occupied, roomNumber);
        }
        currentRoom.numOccupants += 1;
    }
}