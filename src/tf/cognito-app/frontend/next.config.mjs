/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**",
      },
    ],
  },
  compiler: {
    reactRemoveProperties:
      process.env.NEXT_PUBLIC_ENV_NAME === "production"
        ? { properties: ["^data-test"] }
        : false,
    removeConsole: process.env.NEXT_PUBLIC_ENV_NAME === "production",
  },
};

export default nextConfig;
