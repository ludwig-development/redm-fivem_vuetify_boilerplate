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


/**
 * Targets the centralized Server Router
 * @param {string} theModule - e.g., 'itemManager'
 * @param {string} action - e.g., 'AddItems' or 'view'
 * @param {object} payload - Any data the server might need, optional
 */
export async function triggerServerAction(action, payload = {}) {
  return await postNUI('ServerRouter', {
    action: action,
    data: payload
  });
}

/**
 * Requests data from the server and waits for a response.
 * @param {string} action - The action name.
 * @param {object} payload - Any data the server might need, optional
 * @returns {Promise<any>} - The data returned from the server.
 */
export async function requestServerData(action, payload = {}) {
  const result = await postNUI('ServerCallbackRouter', {
    action: action,
    data: payload
  });

  return result;
}