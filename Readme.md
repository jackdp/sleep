# Sleep

Sleep is a small console application that pauses execution of a script/terminal for a specified amount of time.
It is very similar to the Linux Sleep program from the [GNU core utils](https://www.gnu.org/software/coreutils/) package.


## Download

Source: https://github.com/jackdp/sleep

Binary (Windows 32-bit, Windows 64-bit): http://www.pazera-software.com/products/sleep/


## Usage

`sleep.exe NUMBER[UNIT] [-st] [-h] [-V] [--license] [--home]`

### Options

| Option               | Description                                    |
|----------------------|------------------------------------------------|
| `-st`, `--show-time` | Show the calculated waiting time.              |
| `-h`, `--help`       | Show this help.                                |
| `-V`, `--version`    | Show application version.                      |
| `--license`          | Display program license.                       |
| `--home`             | Opens program homepage in the default browser. |

### NUMBER

Any combination of real, integer, hexadecimal, or binary numbers. Each number may be followed by a time unit suffix. The total waiting time will be the sum of all the numbers provided.  
The decimal separator in real numbers can be `.` (period) or `,` (comma).  
Hexadecimal numbers must be prefixed with `0x` or `$` (dollar), eg. `0x0A`, `$0A`.  
The letter `D` at the end of the number is treated as a unit of time (days), so if you want to set the wait time to `$0D`seconds, you must use `$ODs` and not `$OD`.  
Binary numbers must be prefixed with `%` (percent), eg. `%1010`.

Maximum waiting time: 2^32 ms = 49d 17:02:47.295  
Timer resolution depends on the operating system and hardware. On my Windows 10: min = 15.625 ms, max = 0.500 ms.

### Time units

| Unit | Description      |
|------|------------------|
| ms   | Millisecond      |
| s    | Second (default) |
| m    | Minute           |
| h    | Hour             |
| d    | Day              |

### Exit codes

| Exit code | Description   |
|-----------|---------------|
| 0         | OK (no error) |
| 1         | Other error   |
| 2         | Syntax error  |

## Examples

1. Pause for 1 second:  
  `sleep 1`  

2. Pause for 3.5 minutes:  
  `sleep 3.5m`  
  `sleep "3.5 m"`  
  `sleep 3m 30s`  
  `sleep 3500ms`  

3. Pause for 12h 12m 42s:  
  `sleep $ABBA`  
  `sleep %1010101110111010`  
  `sleep 12h 12m 42s`  

4. Pause for 2 minutes and 50 seconds:  
  `sleep 2m 50s`  
  `sleep 3m "-10s"`  
  `sleep 1.7e+2`  

## Compilation

To compile, you need the [Lazarus IDE](https://www.lazarus-ide.org/) and several units from the [JPLib](https://github.com/jackdp/JPLib) package.

How to build:

1. Install **JPLib** package in the Lazarus IDE.
1. Open `src\Sleep.lpi` file with the Lazarus.
1. Build project (menu `Run->Build`).


## Releases

2020.08.25 - Version 1.0
