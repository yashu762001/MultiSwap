<h1> MultiSwap </h1>
<h2> Key Features of this application : </h2>
<ul>
  <li> Add Liquidity </li>
  <li> Swap a token with any other token </li>
  <li> Swap a token with any other 2 tokens </li>
  
</ul>

<h2> Add Liquidity : </h2>
<p> Basically I am creating a pool of tokens. But each pool has one ethereum and another ERC20 token. The total value of ethereum and token in each pool is same. At the time of creation of pool the creator decides the value of each token wrt ethereum. Any subsequent liquidity provider follows that ratio.
  All the liquidites are stored in the smart contract. No withdraw function is developed so even the developer of contract cannot take out tokens from the contract. So contract can be trusted. </p>

<h2> Swap a token with another token : </h2>
<p> The underlying alogrithm behind it is Automated Market Maker. Basically Let's say user wants to exchange 100 DAI for ETH. So if within the pool the value was 1ETH=5DAI. then for 100 dai the person will get 20ETH. and the pool will be updated with original count of DAI  + 100 and ETH would be updated with
  existing ETH-20. Now Let's a user want to exchange 100 DAI for UNI, then first we will use DAI-ETH and then ETH-UNI. This way we are able to find relation between DAI and ETH. </p>
  
<h2> Swap token with 2 tokens : </h2>
<p> This is an extension of above algorithm. The user chooses what percentage of his swapping should come with 1 token and what percenatage with another. For example
  user wants to swap ETH for DAI and UNI. He wants 60% of the value of ETH should from DAI and remaining 40% from UNI. So let's say 100 ETH were supposed to be swapped
  with DAI and UNI. 1ETH=5DAI and 1ETH=4UNI. Since 60% only in DAI so 300 DAI would be received and 400 UNI. </p>
  

<h2> Difficulties Faced : </h2>
<ul>
  <li> The most time spent was on how to let contract accpet tokens from the user. Since I am using ERC20 token so for transferring them I needed to approve that yes I am allowing the contract to withdraw money from my contract.
      Earlier I was approving in the smart contract itself but was getting error continuously. Finally I realised that this approval has to come from user side and then finally this error was sorted.
  </li>
  
  <li> The next error that irritated me was Stack too deep, try removing local variables. I have programmed in muliple lanaguages but never got an error regarding number of variables I can declare in a function. 
    Finally I stored the local variables in a struct and then used them within function which ultimately sorted the error. </li>
  
  <li> It took me little bit effort to figure out how I can do routing, how I can create a liquidity pool and how to implement AMM Algorithm. </li>
  
 </ul>
 
 <h2> Future Improvements within this application : </h2>
 <p> So currently this application only works for ERC20 tokens with 18 decimal places. For other tokens I will have to figure out a way to use them within my existing algorithm. </p> 
