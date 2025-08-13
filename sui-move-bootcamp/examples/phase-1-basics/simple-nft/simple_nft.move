module simple_nft::simple_nft {
    // Import the necessary types for strings and URLs.
    use std::string;
    use sui::url::{Url, new_unsafe_from_bytes};
    use sui::object;
    use sui::tx_context::TxContext;

    // Define the NFT struct. It will be stored on-chain.
    public struct SimpleNFT has key, store {
        id: object::UID,             // Unique ID for the NFT object.
        name: string::String,        // Name of the NFT.
        image_url: Url,              // Image link for the NFT.
    }

    // Function to mint a new NFT.
    public fun mint(
        name: vector<u8>,           // Name as bytes (utf8).
        image_url: vector<u8>,
        recipient: address,      // Image link as bytes (utf8).
        ctx: &mut TxContext         // Transaction context.
    ){
        let nft = SimpleNFT {
            id: object::new(ctx),                       // Generate a new unique ID for the NFT.
            name: string::utf8(name),                   // Convert the name bytes to a String.
            image_url: new_unsafe_from_bytes(image_url) // Convert the image link bytes to a Url.
        }
        transfer::public_transfer(nft, recipient); // Transfer the NFT to the recipient.
}


    // Function to get the name of the NFT.
    public fun get_name(nft: &SimpleNFT): &string::String {
        &nft.name
    }

    // Function to get the image link of the NFT.
    public fun get_image_url(nft: &SimpleNFT): &Url {
        &nft.image_url
    }
}
