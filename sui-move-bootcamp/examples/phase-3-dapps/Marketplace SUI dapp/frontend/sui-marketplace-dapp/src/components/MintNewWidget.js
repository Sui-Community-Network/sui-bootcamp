import React, { useEffect } from "react";
import { useWalletKit } from "@mysten/wallet-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { toast } from "react-toastify";

function MintNewWidget({ setAccountAddress, packageId, afterMintingWidget }) {
  const { currentAccount, signAndExecuteTransactionBlock } = useWalletKit();

  useEffect(() => {
    if (currentAccount?.address) {
      setAccountAddress(currentAccount.address);
    }
  }, [currentAccount, setAccountAddress]);

  const mintNewWidget = async () => {
    try {
      const txb = new TransactionBlock();
txb.moveCall({
  target: `${packageId}::widget::mint`,
});

// sign and execute transaction block with wallet
const output = await signAndExecuteTransactionBlock({
  transactionBlock: txb,
  options: { showEffects: true },
});

console.log("output from minting widget:", output);

      if (afterMintingWidget) {
        await afterMintingWidget();
      }

      toast.success("Successfully minted widget!", {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      alert("Failed to create widget item");
      console.log(e);
    }
  };

  return (
    <div>
      <button className="button" onClick={mintNewWidget}>
        mint new widget
      </button>
    </div>
  );
}

export default MintNewWidget;
