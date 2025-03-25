# Foundry Smart Contract Lottery

This project is a decentralized lottery system built using Foundry, a smart contract development framework. It allows users to participate in a lottery by sending Ether to the contract, and a winner is randomly selected after a certain period.

## Features

- **Decentralized**: No central authority controls the lottery.
- **Transparent**: All transactions and contract logic are publicly verifiable.
- **Secure**: Built with Foundry, ensuring robust and secure smart contract development.

## Getting Started

### Prerequisites

- Foundry installed on your machine.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/emhaihsan/foundry-smart-contract-lottery.git
   ```
2. Navigate to the project directory:
   ```bash
   cd foundry-smart-contract-lottery
   ```
3. Install dependencies:
   ```bash
   forge install
   ```

### Usage

1. Compile the contracts:
   ```bash
   forge build
   ```
2. Run the tests:
   ```bash
   forge test
   ```
3. Deploy the contract:
   ```bash
   forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/Lottery.sol:Lottery
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
