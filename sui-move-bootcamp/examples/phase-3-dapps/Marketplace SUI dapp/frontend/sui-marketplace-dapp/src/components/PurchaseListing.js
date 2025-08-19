import React from "react";
import { useWalletKit } from "@mysten/wallet-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { toast } from "react-toastify";

function PurchaseListing({ itemToPurchase, amountSent, packageId, marketplaceId, afterPurchase }) {
  const { signAndExecuteTransactionBlock } = useWalletKit();

  const purchaseListing = async () => {
    try {
      // prepare transaction block, split coin
const txb = new TransactionBlock();
const [coin] = txb.splitCoins(txb.gas, [txb.pure(amountSent)]);

// prepare transaction block
txb.moveCall({
  target: `${packageId}::marketplace::buy_and_take`,
  typeArguments: [`${packageId}::widget::Widget`, "0x2::sui::SUI"],
  arguments: [txb.object(marketplaceId), txb.pure(itemToPurchase), coin],
});

// sign and execute transaction block with wallet
const output = await signAndExecuteTransactionBlock({
  transactionBlock: txb,
  options: { showEffects: true },
});

console.log("output:", output);

      if (afterPurchase) {
        await afterPurchase();
      }

      toast.success(`Successfully purchased!`, {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      console.log(e);
      alert("Failed to purchase listing");
    }
  };
  return (
    <div>
      <button className="button" onClick={purchaseListing}>
        purchase item
      </button>
    </div>
  );
}

export default PurchaseListing;
