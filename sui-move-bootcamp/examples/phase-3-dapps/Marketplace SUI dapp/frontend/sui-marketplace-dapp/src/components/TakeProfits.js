import React from "react";
import { useWalletKit } from "@mysten/wallet-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { toast } from "react-toastify";

function TakeProfits({ packageId, marketplaceId }) {
  const { signAndExecuteTransactionBlock } = useWalletKit();

  const takeProfits = async () => {
    try {
      const txb = new TransactionBlock();
txb.moveCall({
  target: `${packageId}::marketplace::take_profits_and_keep`,
  typeArguments: ["0x2::sui::SUI"],
  arguments: [txb.object(marketplaceId)],
});

// sign and execute transaction block with wallet
const output = await signAndExecuteTransactionBlock({
  transactionBlock: txb,
  options: { showEffects: true },
});

console.log("output:", output);

      toast.success(`Successfully took profits!`, {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      console.log(e);
      alert("Failed to take profits");
    }
  };
  return (
    <div>
      <button className="button" onClick={takeProfits}>
        take profits
      </button>
    </div>
  );
}

export default TakeProfits;
