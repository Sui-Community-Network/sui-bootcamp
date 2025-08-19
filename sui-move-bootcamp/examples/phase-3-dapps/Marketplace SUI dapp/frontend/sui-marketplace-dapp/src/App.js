// react libraries
import React, { useState } from "react";
import "./App.css";

// components
import MintNewWidget from "./components/MintNewWidget";
import ListItem from "./components/ListItem";
import PurchaseListing from "./components/PurchaseListing";
import TakeProfits from "./components/TakeProfits";

// toastify libraries
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

// sui libraries
import { WalletKitProvider, ConnectButton } from "@mysten/wallet-kit";
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";

function App() {
  const [marketplaceId, setMarketplaceId] = useState("");
  const [packageId, setPackageId] = useState("");
  const [idsEntered, setIdsEntered] = useState(false);
  const [accountAddress, setAccountAddress] = useState("");
  const [ownedWidgets, setOwnedWidgets] = useState("");
  const [widgetToList, setWidgetToList] = useState("");
  const [price, setPrice] = useState("");
  const [itemToPurchase, setItemToPurchase] = useState("");
  const [listingInfo, setListingInfo] = useState("");
  const [amountSent, setAmountSent] = useState("");

  const handleMarketplaceIdInput = (event) => {
    setMarketplaceId(event.target.value);
  };

  const handlePackageIdInput = (event) => {
    setPackageId(event.target.value);
  };

  const handleSubmit = () => {
    if (marketplaceId.trim() !== "" && packageId.trim() !== "") {
      setIdsEntered(true);
    } else {
      alert("Please enter your PackageID and MarketplaceID");
    }
  };

  const handleWidgetInput = (event) => {
    setWidgetToList(event.target.value);
  };

  const handlePriceInput = (event) => {
    setPrice(event.target.value);
  };

  const handleItemToPurchaseInput = (event) => {
    setItemToPurchase(event.target.value);
  };

  const handleAmountSentInput = (event) => {
    setAmountSent(event.target.value);
  };

  const getOwnedWidgets = async () => {
    try {
      const suiClient = new SuiClient({ url: getFullnodeUrl("devnet") });
const objects = await suiClient.getOwnedObjects({ owner: accountAddress });
const widgets = [];

// iterate through all objects owned by address
for (let i = 0; i < objects.data.length; i++) {
  const currentObjectId = objects.data[i].data.objectId;

  // get object information
  const objectInfo = await suiClient.getObject({
    id: currentObjectId,
    options: { showContent: true },
  });

  if (objectInfo.data.content.type == `${packageId}::widget::Widget`) {
    const widgetObjectId = objectInfo.data.content.fields.id.id;
    console.log("widget spotted:", widgetObjectId);
    widgets.push(widgetObjectId);
  }
}
setOwnedWidgets(widgets);

      toast.success(`Successfully refreshed owned widgets!`, {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      alert("Failed to refresh");
      console.log(e);
    }
  };

  const afterListing = async () => {
    await getOwnedWidgets();
  };

  const afterPurchase = async () => {
    await getListingInformation();
    await getOwnedWidgets();
  };

  const afterMintingWidget = async () => {
    await getOwnedWidgets();
  };

  const getListingInformation = async () => {
    try {
      const suiClient = new SuiClient({ url: getFullnodeUrl("devnet") });

// get marketplace ID
const marketplaceObject = await suiClient.getObject({
  id: marketplaceId,
  options: { showContent: true },
});
const marketplaceItemsId = marketplaceObject.data.content.fields.items.fields.id.id;

// get marketplace items ID
const marketplaceItems = await suiClient.getDynamicFields({ parentId: marketplaceItemsId });

const listingIds = [];
// get listing IDs - loop through and save IDs
for (let i = 0; i < marketplaceItems.data.length; i++) {
  listingIds.push(marketplaceItems.data[i].objectId);
}

const output = [];
// iterate through all listings and populate output array
for (let i = 0; i < listingIds.length; i++) {
  const currentListing = [];
  const listingObject = await suiClient.getObject({
    id: listingIds[i],
    options: { showContent: true },
  });

  // save relevant info into an array for displaying on frontend
  currentListing.push(`listingId: ${listingIds[i]}`);
  currentListing.push(`askPrice: ${listingObject.data.content.fields.value.fields.ask}`);
  currentListing.push(`owner: ${listingObject.data.content.fields.value.fields.owner}`);
  currentListing.push(`widget: ${listingObject.data.content.fields.name}`);
  output.push(currentListing);
}

setListingInfo(output);

      toast.success(`Successfully refreshed listings!`, {
        position: toast.POSITION.TOP_LEFT,
        autoClose: 3000,
      });
    } catch (e) {
      alert("Failed to get listing information");
      console.log(e);
    }
  };

  return (
    <WalletKitProvider>
      <ToastContainer />
      {!idsEntered ? (
        <div className="centered">
          <input type="text" value={packageId} onChange={handlePackageIdInput} placeholder="Enter PackageId" />
          <input type="text" value={marketplaceId} onChange={handleMarketplaceIdInput} placeholder="Enter MarketplaceId" />
          <button className="button" onClick={handleSubmit}>
            Submit
          </button>
        </div>
      ) : (
        <div>
          <div class="header">
            <div class="column header-left title">MarketplaceId: {marketplaceId}</div>
            <div class="header-right"><ConnectButton /></div>
          </div>
          <div class="row" id="second-row">
            <div class="column">
              <img src="marketplace-banner.png" alt="Banner" className="banner-image"></img>
            </div>
            <div class="column">
              <div class="sub-row">
                <MintNewWidget setAccountAddress={setAccountAddress} packageId={packageId} afterMintingWidget={afterMintingWidget} />
              </div>
              <div class="sub-row">
                <button className="button" onClick={getOwnedWidgets}>
                  get owned widgets
                </button>
              </div>

              <div class="sub-row">
                <div class="input-container">
                  <div class="column1">
                    <ListItem
                      widgetToList={widgetToList}
                      price={price}
                      packageId={packageId}
                      marketplaceId={marketplaceId}
                      afterListing={afterListing}
                    />
                  </div>
                  <div class="column column2">
                    <div class="row row1">
                      <input type="text" value={widgetToList} onChange={handleWidgetInput} placeholder="input widgetId" />
                    </div>
                    <div class="row row2">
                      <input type="number" value={price} onChange={handlePriceInput} placeholder="input price" />
                    </div>
                  </div>
                </div>
              </div>

              <div class="sub-row">
                <button className="button" onClick={getListingInformation}>
                  get listings
                </button>
              </div>

              <div class="sub-row">
                <div class="input-container">
                  <div class="column column1">
                    <PurchaseListing
                      itemToPurchase={itemToPurchase}
                      amountSent={amountSent}
                      packageId={packageId}
                      marketplaceId={marketplaceId}
                      afterPurchase={afterPurchase}
                    />
                  </div>
                  <div class="column column2">
                    <div class="row row1">
                      <input type="text" value={itemToPurchase} onChange={handleItemToPurchaseInput} placeholder="input itemId" />
                    </div>
                    <div class="row row2">
                      <input type="number" value={amountSent} onChange={handleAmountSentInput} placeholder="input amount" />
                    </div>
                  </div>
                </div>
              </div>

              <div class="sub-row">
                <TakeProfits packageId={packageId} marketplaceId={marketplaceId} />
              </div>
            </div>
          </div>
          <div class="row" id="third-row">
            <div class="column">
              <div class="title">Listings:</div>
              <div className="listing-info text">
                <ul>
                  {listingInfo &&
                    listingInfo.map((listing, idx) => {
                      return (
                        <li>
                          Item {idx}
                          <ul>
                            {listing.map((info, infoIdx) => {
                              return <li>{info}</li>;
                            })}
                          </ul>
                        </li>
                      );
                    })}
                </ul>
              </div>
            </div>

            <div class="column">
              <div className="title">Currently owned widgets:</div>
              <div className="text">
                <ul>
                  {ownedWidgets &&
                    ownedWidgets.map((widget, idx) => {
                      return <li>{widget}</li>;
                    })}
                </ul>
              </div>
            </div>
          </div>
        </div>
      )}
    </WalletKitProvider>
  );
}

export default App;
