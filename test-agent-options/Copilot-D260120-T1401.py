#!/usr/bin/env python3
"""
Factorial calculator supporting values up to 50!
"""
import sys


def factorial(n):
    """Calculate factorial of n (n!)"""
    if n < 0:
        raise ValueError("Factorial is not defined for negative numbers")
    if n == 0 or n == 1:
        return 1
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def run_tests():
    """Run test cases for factorial function"""
    test_cases = [0, 1, 5, 25, 50]
    print("Running factorial tests:")
    print("-" * 50)
    for n in test_cases:
        result = factorial(n)
        print(f"{n}! = {result}")
    print("-" * 50)


def main():
    if len(sys.argv) == 1:
        # No arguments provided - show usage and run tests
        print("Usage: python Copilot-D260120-T1401.py <N>")
        print("Calculate factorial of N (supports up to 50!)\n")
        run_tests()
    else:
        # Calculate factorial for provided argument
        try:
            n = int(sys.argv[1])
            if n < 0 or n > 50:
                print(f"Error: N must be between 0 and 50")
                sys.exit(1)
            result = factorial(n)
            print(f"{n}! = {result}")
        except ValueError as e:
            print(f"Error: {e}")
            sys.exit(1)


if __name__ == "__main__":
    main()
