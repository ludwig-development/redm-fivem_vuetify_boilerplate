import axios from 'axios';

/**
 * Helper to send data back to the RedM/FiveM client.
 * @param {string} eventName - The name of the RegisterNUICallback in Lua.
 * @param {object} data - The data payload to send.
 */

export async function postNUI(eventName, data = {}) {
  const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'your_resource_name';

  try {
    const response = await fetch(`https://${resourceName}/${eventName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data),
    });

    return await response.json();
  } catch (error) {
    console.error(`NUI Callback Error: ${eventName}`, error);
    return null;
  }
}