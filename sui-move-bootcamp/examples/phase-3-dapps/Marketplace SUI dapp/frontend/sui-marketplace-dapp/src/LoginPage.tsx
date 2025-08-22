import { useState, useEffect, useCallback } from "react"
import { Button } from "../../components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "../../components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../components/ui/tabs"
import { Wallet, Shield } from "lucide-react"
import { useNavigate } from "react-router-dom"

import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519"
import { generateNonce, generateRandomness } from "@mysten/sui/zklogin"
import { SuiClient } from "@mysten/sui/client"
import { jwtDecode } from "jwt-decode"
import { jwtToAddress } from "@mysten/sui/zklogin"
import {
  useCurrentAccount,
  useConnectWallet,
  useWallets,
  useAccounts,
  useSwitchAccount,
  useDisconnectWallet,
} from "@mysten/dapp-kit"

export interface JwtPayload {
  iss?: string
  sub?: string
  aud?: string[] | string
  exp?: number
  nbf?: number
  iat?: number
  jti?: string
}

const FULLNODE_URL = "https://fullnode.testnet.sui.io"
const suiClient = new SuiClient({ url: FULLNODE_URL })
const CLIENT_ID = "135467475488-rft07g4ulahjiajlfdh1uf080qkjgput.apps.googleusercontent.com"
const REDIRECT_URI = "http://localhost:5173/login"

export default function LoginPage() {
  const [isLoading, setIsLoading] = useState(false)
  const [loginURL, setLoginURL] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [mounted, setMounted] = useState(false)
  const [showAccountList, setShowAccountList] = useState(false)
  const navigate = useNavigate()
  const currentAccount = useCurrentAccount()
  const { mutate: connect } = useConnectWallet()
  const wallets = useWallets()
  const accounts = useAccounts()
  const { mutateAsync: switchAccount } = useSwitchAccount()
  const { mutateAsync: disconnect } = useDisconnectWallet()

  // Setup login URL for zkLogin
  const setupLoginURL = useCallback(async () => {
    try {
      setIsLoading(true)
      const { epoch } = await suiClient.getLatestSuiSystemState()
      const maxEpoch = Number(epoch) + 2
      const ephemeralKeyPair = new Ed25519Keypair()
      const randomness = generateRandomness()
      const nonce = generateNonce(ephemeralKeyPair.getPublicKey(), maxEpoch, randomness)

      if (typeof window !== "undefined") {
        localStorage.setItem("zklogin_randomness", randomness)
        localStorage.setItem("zklogin_max_epoch", maxEpoch.toString())
      }

      const params = new URLSearchParams({
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "id_token",
        scope: "openid email profile",
        nonce: nonce,
      })

      setLoginURL(`https://accounts.google.com/o/oauth2/v2/auth?${params}`)
    } catch (err) {
      setError("Failed to setup login. Please try again.")
      console.error("Setup login error:", err)
    } finally {
      setIsLoading(false)
    }
  }, [])

  // Handle successful zkLogin
  const handleLoginSuccess = useCallback(
    async (token: string) => {
      try {
        setIsLoading(true)
        const decoded = jwtDecode<JwtPayload>(token)
        console.log("Decoded JWT:", decoded)

        if (typeof window === "undefined") return

        let salt = localStorage.getItem("zklogin_salt")
        if (!salt) {
          const array = new Uint8Array(16)
          window.crypto.getRandomValues(array)
          salt = Array.from(array)
            .map((b) => b.toString(16).padStart(2, "0"))
            .join("")
          localStorage.setItem("zklogin_salt", salt)
        }

        // Convert hex string to BigInt
        const address = jwtToAddress(token, BigInt("0x" + salt))

        localStorage.setItem("zklogin_jwt", token)
        localStorage.setItem("zklogin_address", address)

        console.log("Login successful! Sui address:", address)
        navigate("/")
      } catch (err) {
        setError("Login failed. Please try again.")
        console.error("Login error:", err)
      } finally {
        setIsLoading(false)
      }
    },
    [navigate],
  )

  // Handle wallet connection
  const handleWalletConnect = () => {
    try {
      setIsLoading(true)
      setError(null)

      // Get the first available wallet
      const availableWallet = wallets[0]

      if (!availableWallet) {
        setError("No wallet found. Please install a Sui wallet extension.")
        setIsLoading(false)
        return
      }

      connect(
        { wallet: availableWallet },
        {
          onSuccess: () => {
            localStorage.setItem("wallet_connected", "true")
            setIsLoading(false)
            navigate("/")
          },
          onError: (error) => {
            console.error("Wallet connection failed:", error)
            setError("Failed to connect wallet. Please try again.")
            setIsLoading(false)
          },
        },
      )
    } catch (err) {
      console.error("Wallet connection error:", err)
      setError("Failed to connect wallet. Please try again.")
      setIsLoading(false)
    }
  }

  // On mount, check for redirect or existing login
  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (!mounted) return

    const existingJWT = localStorage.getItem("zklogin_jwt")
    const existingAddress = localStorage.getItem("zklogin_address")

    if (existingJWT && existingAddress) {
      navigate("/")
      return
    }

    if (currentAccount) {
      localStorage.setItem("wallet_connected", "true")
      navigate("/")
      return
    }

    // Google returns id_token in the hash fragment
    if (typeof window !== "undefined") {
      const urlParams = new URLSearchParams(window.location.hash.substring(1))
      const token = urlParams.get("id_token")

      if (token) {
        handleLoginSuccess(token)
        return
      }
    }

    setupLoginURL()
  }, [navigate, currentAccount, handleLoginSuccess, setupLoginURL, mounted])

  if (!mounted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white to-orange-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white to-orange-50">
      <div className="container mx-auto p-6">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">Welcome To Sayari</h1>
          <p className="text-gray-600">Sign in to access Sayari Platform</p>
        </div>

        <div className="flex justify-center">
          <div className="w-full max-w-md px-4">
            <Card
              className="border-2 border-orange-300 shadow-xl bg-white overflow-hidden"
              style={{ borderColor: "#fdba74", boxShadow: "0 25px 50px -12px rgba(251, 146, 60, 0.25)" }}
            >
              <CardHeader
                className="bg-orange-200 border-b-2 border-orange-300 p-6"
                style={{ backgroundColor: "#fed7aa", borderBottomColor: "#fdba74" }}
              >
                <CardTitle className="text-center text-orange-900 text-xl font-bold" style={{ color: "#9a3412" }}>
                  Choose Your Login Method
                </CardTitle>
              </CardHeader>
              <CardContent className="p-6">
                <Tabs defaultValue="wallet" className="w-full">
                  <TabsList
                    className="grid w-full grid-cols-2 mb-6 p-1 rounded-lg h-12"
                    style={{
                      backgroundColor: "#f3f4f6",
                      borderColor: "#fdba74",
                      border: "2px solid #fdba74",
                      gap: "4px",
                    }}
                  >
                    <TabsTrigger
                      value="wallet"
                      className="flex items-center justify-center gap-2 h-full rounded-md font-medium transition-all duration-200 flex-1"
                      style={{
                        backgroundColor: "white",
                        color: "#6b7280",
                        border: "none",
                        minHeight: "40px",
                      }}
                    >
                      <Wallet className="w-4 h-4" />
                      Wallet
                    </TabsTrigger>
                    <TabsTrigger
                      value="zk"
                      className="flex items-center justify-center gap-2 h-full rounded-md font-medium transition-all duration-200 flex-1"
                      style={{
                        backgroundColor: "white",
                        color: "#6b7280",
                        border: "none",
                        minHeight: "40px",
                      }}
                    >
                      <Shield className="w-4 h-4" />
                      ZK Login
                    </TabsTrigger>
                  </TabsList>

                  <TabsContent value="wallet" className="space-y-4">
                    <div className="text-center mb-4">
                      <h3 className="text-lg font-semibold text-gray-800 mb-2">Connect Your Wallet</h3>
                      <p className="text-sm text-gray-600">Connect your wallet to access the blockchain</p>
                    </div>

                    {error && (
                      <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                        <p className="text-red-600 text-sm">{error}</p>
                      </div>
                    )}

                    <div className="flex justify-center">
                      <Button
                        onClick={handleWalletConnect}
                        variant="outline"
                        className="w-full h-auto p-4 border-orange-200 bg-white text-gray-800 hover:bg-white hover:border-orange-200"
                        disabled={isLoading || wallets.length === 0}
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center gap-2">
                            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-orange-600"></div>
                            Connecting...
                          </div>
                        ) : wallets.length === 0 ? (
                          <div className="flex items-center justify-center gap-2">
                            <Wallet className="w-5 h-5" />
                            No Wallet Found
                          </div>
                        ) : (
                          <div className="flex items-center justify-center gap-2">
                            <Wallet className="w-5 h-5" />
                            Connect {wallets[0]?.name || "Wallet"}
                          </div>
                        )}
                      </Button>
                    </div>

                    {wallets.length === 0 && (
                      <div className="text-center text-sm text-gray-500 mt-2">
                        Please install a Sui wallet extension to continue
                      </div>
                    )}

                    {/* Account switcher and disconnect UI */}
                    {currentAccount && (
                      <div className="mt-4">
                        <div className="flex items-center justify-between bg-gray-100 p-2 rounded">
                          <span className="text-sm text-gray-700">
                            Connected: {currentAccount.address.slice(0, 6)}...{currentAccount.address.slice(-4)}
                          </span>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setShowAccountList((v) => !v)}
                          >
                            Switch Account
                          </Button>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => disconnect()}
                          >
                            Disconnect
                          </Button>
                        </div>
                        {showAccountList && (
                          <div className="mt-2 bg-white border rounded shadow">
                            {accounts.map((account) => (
                              <div
                                key={account.address}
                                className={`p-2 cursor-pointer hover:bg-orange-100 ${
                                  account.address === currentAccount.address ? "font-bold" : ""
                                }`}
                                onClick={async () => {
                                  await switchAccount({ account })
                                  setShowAccountList(false)
                                }}
                              >
                                {account.address.slice(0, 6)}...{account.address.slice(-4)}
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    )}
                  </TabsContent>

                  <TabsContent value="zk" className="space-y-4">
                    <div className="text-center mb-4">
                      <h3 className="text-lg font-semibold text-gray-800 mb-2">ZK Login</h3>
                      <p className="text-sm text-gray-600">Sign in with zero-knowledge proof authentication</p>
                    </div>

                    {error && (
                      <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                        <p className="text-red-600 text-sm">{error}</p>
                      </div>
                    )}

                    <Button
                      onClick={() => {
                        if (loginURL) window.location.href = loginURL
                      }}
                      className="w-full bg-orange-500 hover:bg-orange-600 text-white py-3"
                      disabled={isLoading || !loginURL}
                    >
                      {isLoading ? (
                        <div className="flex items-center justify-center gap-2">
                          <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                          Redirecting...
                        </div>
                      ) : (
                        <div className="flex items-center justify-center gap-2">
                          <Shield className="w-4 h-4" />
                          Sign In with ZK Login
                        </div>
                      )}
                    </Button>

                    <div className="text-center text-sm text-gray-500 mt-4">
                      You will be redirected to complete authentication
                    </div>
                  </TabsContent>
                </Tabs>

                <div className="mt-6 pt-6 border-t border-orange-200">
                  <p className="text-center text-sm text-gray-600">
                    New to Sayari?{" "}
                    <span
                      className="cursor-pointer font-medium transition-colors duration-200"
                      style={{
                        color: "#f97316",
                      }}
                      onMouseEnter={(e) => {
                        ;(e.target as HTMLElement).style.color = "#ea580c"
                      }}
                      onMouseLeave={(e) => {
                        ;(e.target as HTMLElement).style.color = "#f97316"
                      }}
                    >
                      Create an account
                    </span>
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}
