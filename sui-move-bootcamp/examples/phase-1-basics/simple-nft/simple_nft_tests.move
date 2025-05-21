#[test_only]
module simple_nft::simple_nft_tests {
    use simple_nft::simple_nft;
    use sui::tx_context::new_tx_context;

    #[test]
    fun test_mint_and_getters() {
        let mut ctx = new_tx_context(@0x1);

        // Mint a new NFT with name "Test NFT" and image link "https://example.com/image.png"
        let nft = simple_nft::mint(
            b"Test NFT",
            b"https://example.com/image.png",
            &mut ctx
        );

        // Check that the name is correct
        assert!(
            *simple_nft::get_name(&nft) == b"Test NFT".to_string(),
            0
        );

        // Check that the image_url is correct
        assert!(
            *simple_nft::get_image_url(&nft) == b"https://example.com/image.png".to_string(),
            1
        );
    }
}
