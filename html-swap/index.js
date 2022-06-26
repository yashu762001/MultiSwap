import { ethers } from "../ethers-5.6.esm.min.js";
import { abi, token_abi, contractAddress } from "../constants.js";

const connectButton = document.getElementById("connect");
const transferButton = document.getElementById("transfer");
const exchanegButton = document.getElementById("exchange");
const swapButton = document.getElementById("swap");

connectButton.onclick = ethereum_connect;
transferButton.onclick = transfer;
exchanegButton.onclick = exchange;
swapButton.onclick = swap;

async function ethereum_connect() {
  console.log("Entered");
  connectButton.disabled = true;
  try {
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });
    console.log(accounts);
    connectButton.innerHTML = "Connected";
  } catch (err) {
    connectButton.disabled = false;
    console.log("Wallet Connection Request Rejected By User");
  }
}

async function transfer() {
  // connecting to blockchain
  // signer/wallet address with some gas
  // contract we are interating with : its ABI and address.

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const swap_contract = new ethers.Contract(contractAddress, abi, signer);
  const tokenAddress = document.getElementById("address").value;
  const amountEth = document.getElementById("amountEth").value;
  const amountToken = document.getElementById("amountToken").value;
  const erc20 = new ethers.Contract(tokenAddress, token_abi, signer);

  const tx = await erc20.approve(
    contractAddress,
    ethers.utils.parseEther("200000000")
  );
  await tx.wait();
  const symbol = await erc20.symbol();
  const temp = amountEth.toString();
  const temp1 = amountToken.toString();
  const tx1 = await swap_contract.addEthereumLiquidity({
    value: ethers.utils.parseEther(temp),
  });
  await tx1.wait(1);
  const add = await ethers.utils.getAddress(tokenAddress);
  const transactionResponse = await swap_contract.addLiquidity(
    add,
    ethers.utils.parseEther(temp),
    ethers.utils.parseEther(temp1),
    symbol
  );
  const transactionReceipt = await transactionResponse.wait(1);

  console.log("Done");
}

async function exchange() {
  const token1 = document.getElementById("token1").value;
  const token2 = document.getElementById("token2").value;
  const amt = document.getElementById("amount").value;

  let temp = token1.toString();
  let temp1 = token2.toString();
  let temp3 = amt.toString();

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const swap_contract = new ethers.Contract(contractAddress, abi, signer);
  const owner_address = await signer.getAddress();
  if (temp != "ETH") {
    const addr = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";
    const erc20 = new ethers.Contract(addr, token_abi, signer);

    const tx = await erc20.approve(
      contractAddress,
      ethers.utils.parseEther("200000000")
    );
    await tx.wait(1);

    const give = await swap_contract.checkTokensYouGetForSingleSwap(
      temp,
      temp1,
      ethers.utils.parseEther(temp3)
    );
    await give.wait(1);

    const result = await swap_contract.getSymbolValue();
    console.log(result / 10 ** 18);
  } else if (temp == "ETH") {
    const tx = await swap_contract.addEthereumLiquidity({
      value: ethers.utils.parseEther(temp3),
    });
    await tx.wait(1);
  }

  // if (token2 == "ETH") {
  //   const tx = await swap_contract.payEther(give);
  // } else {
  //   const addr = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
  //   const erc20 = new ethers.Contract(addr, token_abi, signer);

  //   const tx = await erc20.approve(
  //     owner_address,
  //     ethers.utils.parseEther("200000000")
  //   );
  //   await tx.wait();

  //   const tx1 = await swap_contract.payToken(temp1, give);
  // }

  console.log("Done");
}

async function swap() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const swap_contract = new ethers.Contract(contractAddress, abi, signer);
  //const owner_address = await signer.getAddress();

  // const token1 = document.getElementById("t1").value;
  // const token2 = document.getElementById("t2").value;
  // const token3 = document.getElementById("t3").value;
  // const per1 = document.getElementById("per1").value;
  // const per2 = document.getElementById("per2").value;
  // const amt = document.getElementById("amt").value;

  // let temp = token1.toString();
  // let temp1 = token2.toString();
  // let temp2 = token3.toString();
  // let temp3 = per1;
  // let temp4 = per2;
  // let temp5 = amt.toString();

  // const provider = new ethers.providers.Web3Provider(window.ethereum);
  // const signer = provider.getSigner();
  // const swap_contract = new ethers.Contract(contractAddress, abi, signer);
  // const owner_address = await signer.getAddress();

  // if (temp == "ETH") {
  //   const tx4 = await swap_contract.addEthereumLiquidity({
  //     value: ethers.utils.parseEther(amt),
  //   });
  //   await tx4.wait(1);
  // } else if (temp != "ETH") {
  //   if (temp == "DAI") {
  //     const addr = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       contractAddress,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   } else if (temp == "UNI") {
  //     const addr = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       contractAddress,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   }
  // }

  // // Now approve for msg.sender to recieve tokens :
  // if (temp1 == "ETH") {
  //   if (temp2 == "DAI") {
  //     const addr = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       owner_address,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   } else if (temp2 == "UNI") {
  //     const addr = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       owner_address,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   }
  // }

  // if (temp2 == "ETH") {
  //   if (temp1 == "DAI") {
  //     const addr = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       owner_address,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   } else if (temp1 == "UNI") {
  //     const addr = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
  //     const erc20 = new ethers.Contract(addr, token_abi, signer);

  //     const tx = await erc20.approve(
  //       owner_address,
  //       ethers.utils.parseEther("200000000")
  //     );
  //     await tx.wait();
  //   }
  // }

  // if (temp1 != "ETH" && temp2 != "ETH") {
  //   const addr = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";
  //   const erc20 = new ethers.Contract(addr, token_abi, signer);

  //   const tx = await erc20.approve(
  //     owner_address,
  //     ethers.utils.parseEther("200000000")
  //   );
  //   await tx.wait();

  //   const addr1 = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
  //   const erc201 = new ethers.Contract(addr1, token_abi, signer);

  //   const tx1 = await erc201.approve(
  //     owner_address,
  //     ethers.utils.parseEther("200000000")
  //   );
  //   await tx1.wait();
  // }

  // const resp = await swap_contract.checkTokensYouGetForMultipleSwap(
  //   temp,
  //   temp1,
  //   temp2,
  //   ethers.utils.parseEther(temp5),
  //   temp3,
  //   temp4
  // );
  // await resp.wait();

  // console.log("Done");
}
