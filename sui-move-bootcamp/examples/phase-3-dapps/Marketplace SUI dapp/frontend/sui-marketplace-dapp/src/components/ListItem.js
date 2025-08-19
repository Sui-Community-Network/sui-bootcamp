import React from "react";
import { useWalletKit } from "@mysten/wallet-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { toast } from "react-toastify";

function ListItem({ widgetToList, price, packageId, marketplaceId, afterListing }) {
  const { signAndExecuteTransactionBlock } = useWalletKit();

  const listItem = async () => {
    try {
      const txb = new TransactionBlock();
txb.moveCall({
  target: `${packageId}::marketplace::list`,
  typeArguments: [`${packageId}::widget::Widget`, "0x2::sui::SUI"],
  arguments: [txb.object(marketplaceId), txb.object(widgetToList), txb.pure(price)],
});

// sign and execute transaction block with wallet
const output = await signAndExecuteTransactionBlock({
  transactionBlock: txb,
  options: { showEffects: true },
});

// iterate through to get ID of listing
const createdObjects = output.effects.created;
console.log("createdObjects:", createdObjects);

      if (afterListing) {
        await afterListing();
      }

      toast.success(`Listing created!`, {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      alert("Failed to list item");
      console.log(e);
    }
  };

  return (
    <div>
      <button className="button" onClick={listItem}>
        list item
      </button>
    </div>
  );
}

export default ListItem;
