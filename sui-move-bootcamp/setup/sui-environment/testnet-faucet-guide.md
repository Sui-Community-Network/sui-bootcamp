# 💧 How to Request SUI Testnet & Devnet Tokens

If you're developing on the Sui blockchain, you’ll need test tokens to deploy and interact with smart contracts. There are multiple ways to get test tokens on Sui:
- Request tokens from the official Sui Web Faucet
- Request tokens from the Sui Discord Bot
- Request test tokens through cURL requests
- Request test tokens through TypeScript SDK

---

## ✅ 1. Request via Sui Web Faucet

The Sui Foundation provides an official web faucet for both Testnet and Devnet. To switch you just switch to your preferred network using the dropdown menu in the top right corner of the page.

![sui-faucet-toggle](/sui-move-bootcamp/assets/screenshots/sui-faucet-toggle.png)

### Links:
- **Testnet**: [https://faucet.sui.io/?network=testnet&address=0xd8133d487f2bd59baf4906ba1b76e29504dd8ab7900a2b1ff4d489eab88d59b1](https://faucet.testnet.sui.io/gas)

### 📝 Steps:
1. Open the appropriate faucet URL.
2. Paste your Sui wallet address.
3. Click **"Request"** to receive tokens.
4. Tokens will be sent to your wallet in a few seconds.

---

## 2. Request via Discord Bot

Sui's Discord server offers a faucet bot for Testnet & Devnet tokens.

### 📝 Steps:
1. Join the official Sui Discord [here](https://discord.com/invite/sui)
2. Go to the `#testnet-faucet` or `#devnet-faucet` channel.
3. Use the command:

```
!faucet <your-address>
```
For example to request from this wallet , `0xd8133d487f2bd59baf4906ba1b76e29504dd8ab7900a2b1ff4d489eab88d59b1` this is how the command would look like:
```
!faucet 0xd8133d487f2bd59baf4906ba1b76e29504dd8ab7900a2b1ff4d489eab88d59b1
```
4. Tokens will be sent to your wallet in a few seconds.

---
## 3. Request via cURL
Use the following cURL command to request tokens directly from the faucet server.
In this case we'll be requesting devnet tokens.

```bash
curl --location --request POST 'https://faucet.devnet.sui.io/v1/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<YOUR SUI ADDRESS>"
    }
}'
```
for testnet you just proceed to replace `devnet` with `testnet` in the url to look like this;

```bash
curl --location --request POST 'https://faucet.testnet.sui.io/v1/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<YOUR SUI ADDRESS>"
    }
}'
```

The output should look like this:
[Expected Output](/sui-move-bootcamp/assets/screenshots/curl-tokens-output.png)
