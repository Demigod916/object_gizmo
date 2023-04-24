import { MutableRefObject, useEffect, useRef } from "react";

const isEnvBrowser = (): boolean => !(window as any).invokeNative

interface NuiMessageData<T = unknown> {
  action: string;
  data: T;
}

type NuiHandlerSignature<T> = (data: T) => void;

export const useNuiEvent = <T = any>(
  action: string,
  handler: (data: T) => void
) => {
  const savedHandler: MutableRefObject<NuiHandlerSignature<T>> = useRef(() => {});

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
      const { action: eventAction, data } = event.data;

      if (savedHandler.current) {
        if (eventAction === action) {
          savedHandler.current(data);
        }
      }
    };

    window.addEventListener("message", eventListener);

    return () => window.removeEventListener("message", eventListener);
  }, [action]);
};

export async function fetchNui<T = any>(eventName: string, data?: any, mockData?: T): Promise<T> {
  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  };

  if (isEnvBrowser() && mockData) return mockData;

  const resourceName = (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'nui-frame-app';

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);

  const respFormatted = await resp.json()

  return respFormatted
}