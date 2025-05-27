const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// ✅ Function 1: Notify the donor when a user requests an item
exports.notifyDonorOnRequest = functions.firestore
  .document("requests/{requestId}")
  .onCreate(async (snap, context) => {
    const request = snap.data();
    const itemId = request.itemId;

    // Get the item details
    const itemSnap = await admin.firestore().collection("donations").doc(itemId).get();
    const item = itemSnap.data();

    // Get the donor ID
    const donorId = item.donorId;

    // Get the donor's FCM token
    const donorSnap = await admin.firestore().collection("users").doc(donorId).get();
    const token = donorSnap.data().fcmToken;

    // Prepare notification payload
    const payload = {
      notification: {
        title: "New Request Received",
        body: `Someone requested your donation: ${item.title}`,
      },
    };

    // Send notification
    if (token) {
      await admin.messaging().sendToDevice(token, payload);
      console.log("Notification sent to donor");
    }
  });

// ✅ Function 2: Notify the requester when the donor accepts the request
exports.notifyRequesterOnAccept = functions.firestore
  .document("requests/{requestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to 'accepted'
    if (before.status !== "accepted" && after.status === "accepted") {
      const requesterId = after.requesterId;

      // Get requester's FCM token
      const requesterSnap = await admin.firestore().collection("users").doc(requesterId).get();
      const token = requesterSnap.data().fcmToken;

      const payload = {
        notification: {
          title: "Request Accepted",
          body: "Your request was accepted by the donor!",
        },
      };

      if (token) {
        await admin.messaging().sendToDevice(token, payload);
        console.log("Notification sent to requester");
      }
    }
  });
