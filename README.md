# Aurora-MultiSend

_**Problem to solve:**_

The aurora foundation needs a fast and easy way of distributing aurora tokens
to multiple investors.

_**How does the contract work?**_

- Aurora Foundation calls the "multisend" function with
  the following parameters :
  - **Recipients** (an array of addresses containing the recipients of the aurora tokens)
  - **Amounts** (an array of numbers containing the amount of aurora each address should receive)
  - **Sum** (the total number of aurora tokens to distribute)

- The function will make a few checks to makes sure all parameters have been  
  entered correctly, loops through the array of addresses, and sends the 
  aurora tokens from the caller (aurora Foundation), to the address in the array,
  with the corresponding amount.

