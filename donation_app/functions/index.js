import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// ✅ Notify Donor on Request
export const notifyDonorOnRequest = onDocumentCreated("requests/{requestId}", async (event) => {
  const request = event.data?.data();
  if (!request) return;

  const itemSnap = await db.collection("donations").doc(request.itemId).get();
  const item = itemSnap.data();
  if (!item) return;

  const donorSnap = await db.collection("users").doc(item.donorId).get();
  const token = donorSnap.data()?.fcmToken;

  if (token) {
    await messaging.sendToDevice(token, {
      notification: {
        title: "New Request Received",
        body: `Someone requested your donation: ${item.title}`,
      },
    });
    console.log("✅ Donor notified");
  }
});

// ✅ Notify Requester on Accept
export const notifyRequesterOnAccept = onDocumentUpdated("requests/{requestId}", async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  if (before.status !== "accepted" && after.status === "accepted") {
    const requesterSnap = await db.collection("users").doc(after.requesterId).get();
    const token = requesterSnap.data()?.fcmToken;

    if (token) {
      await messaging.sendToDevice(token, {
        notification: {
          title: "Request Accepted",
          body: "Your request was accepted by the donor!",
        },
      });
      console.log("✅ Requester notified");
    }
  }
});
