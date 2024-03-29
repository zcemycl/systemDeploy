"use client";
import React, {
  useState,
  Dispatch,
  SetStateAction,
  createContext,
  useContext,
  useMemo,
} from "react";
interface OpenBarContextType {
  isDropDownOpen: boolean;
  setIsDropDownOpen: Dispatch<SetStateAction<boolean>>;
  isSideBarOpen: boolean;
  setIsSideBarOpen: Dispatch<SetStateAction<boolean>>;
}

export const OpenBarContext = createContext<OpenBarContextType>({
  isDropDownOpen: false,
  setIsDropDownOpen: function (value: React.SetStateAction<boolean>): void {
    throw new Error("Function not implemented.");
  },
  isSideBarOpen: false,
  setIsSideBarOpen: function (value: React.SetStateAction<boolean>): void {
    throw new Error("Function not implemented.");
  },
});

export const OpenBarProvider = ({
  children,
}: {
  children?: React.ReactNode;
}) => {
  const [isDropDownOpen, setIsDropDownOpen] = useState(false);
  const [isSideBarOpen, setIsSideBarOpen] = useState(false);

  const OpenBarProviderValue = useMemo<OpenBarContextType>(() => {
    return {
      isDropDownOpen,
      setIsDropDownOpen,
      isSideBarOpen,
      setIsSideBarOpen,
    };
  }, [isDropDownOpen, setIsDropDownOpen, isSideBarOpen, setIsSideBarOpen]);

  return (
    <OpenBarContext.Provider value={OpenBarProviderValue}>
      {children}
    </OpenBarContext.Provider>
  );
};

export const useOpenBar = () => useContext(OpenBarContext);
