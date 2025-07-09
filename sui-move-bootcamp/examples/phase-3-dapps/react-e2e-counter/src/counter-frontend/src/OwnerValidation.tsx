import {useState, useEffect} from 'react';
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { Flex } from "@radix-ui/themes";
import { useNetworkVariable } from "./networkConfig";

export default function OwnerValidation() {
  const [isOwner, setIsOwner] = useState(false);
  const counterPackageId = useNetworkVariable("counterPackageId");
  const account = useCurrentAccount();
  
  // Get all owned objects to find counter objects
  const { data: ownedObjects, isPending: isLoadingOwned, error: ownedError } = useSuiClientQuery(
    "getOwnedObjects",
    {
      owner: account?.address as string,
    },
    {
      enabled: !!account,
    }
  );

  useEffect(() => {
    if (ownedObjects && account && counterPackageId) {
      // Find counter objects owned by the current account
      const counterObjects = ownedObjects.data.filter(obj => {
        // You might need to adjust this filter based on your counter object type
        // This assumes the counter object type contains your package ID
        return obj.data?.type?.includes(counterPackageId);
      });
      
      // If the user owns any counter objects, they are considered an owner
      setIsOwner(counterObjects.length > 0);
    } else {
      setIsOwner(false);
    }
  }, [ownedObjects, account, counterPackageId]);

  // Don't render anything if user is not connected
  if (!account) {
    return null;
  }

  // Don't render while loading
  if (isLoadingOwned) {
    return (
      <Flex justify="center" align="center" p="4">
        <div>Loading ownership status...</div>
      </Flex>
    );
  }

  // Handle error state
  if (ownedError) {
    return (
      <Flex justify="center" align="center" p="4">
        <div>Error checking ownership status</div>
      </Flex>
    );
  }

  return (
    <Flex justify="center" align="center" p="4">
      <div style={{
        padding: '12px 24px',
        borderRadius: '8px',
        backgroundColor: isOwner ? '#d4edda' : '#f8d7da',
        border: `1px solid ${isOwner ? '#c3e6cb' : '#f5c6cb'}`,
        color: isOwner ? '#155724' : '#721c24',
        fontWeight: '500'
      }}>
        {isOwner ? 'You are the owner' : 'You are not the owner'}
      </div>
    </Flex>
  );
}