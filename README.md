# Morpalia - Connect Four AI in Prolog

A Connect Four implementation in Prolog featuring an AI opponent using the negamax algorithm with alpha-beta pruning and multiple heuristics.

## Features

- Interactive game board with color-coded pieces
- Smart AI using:
  - Negamax with alpha-beta pruning
  - Dynamic depth calculation
  - Multiple heuristics (sequence, center control, threats)
  - Opening book for early game
  - Position complexity assessment
  - Time management

## Prerequisites

- **SWI-Prolog**

## Project Structure

- `main.pl`: Main game logic and AI implementation.
- `Makefile`: File with commands to easily run or interact with the game.

## Setup and Running the Game

1. **Install SWI-Prolog**:  
   If SWI-Prolog is not installed, download and install it from [SWI-Prolog's official site](https://www.swi-prolog.org/Download.html).

2. **Open the Project**:

   - Open a terminal or command prompt.
   - Navigate to the project directory.

### Running with Makefile Commands

You can use the Makefile commands to start the game or enter the Prolog REPL:

- **Start the Game**:

  ```bash
  make run
  ```

  This command runs the game directly, displaying the board.

- **Start Prolog REPL with Game Loaded**:

  ```bash
  make repl
  ```

  This opens the SWI-Prolog interactive console with `main.pl` loaded, allowing you to run commands manually.

- **Clean Temporary Files**:

  ```bash
  make clean
  ```

  Removes any temporary files generated during gameplay or development.

- **Show Makefile Commands**:
  ```bash
  make help
  ```
  Displays all available Makefile commands and their descriptions.

### Running Manually with SWI-Prolog

1. **Start SWI-Prolog**:

   ```bash
   swipl
   ```

2. **Load the Game File**:

   ```prolog
   ?- [main].
   ```

3. **Start Playing**:
   ```prolog
   ?- play(X).
   ```
   Replace `X` with a column number (1 through 7) to place a piece in that column. The game will display the board and prompt the AI’s move in response.

### Game Commands

- `board.`: View the current game board.
- `reset_board.`: Clears the game board, allowing for a new game.
- `make_move/3`: Manually add a pawn if debugging or exploring moves.
- `undo_move/1`: Remove the last pawn from a column if a mistake was made.
