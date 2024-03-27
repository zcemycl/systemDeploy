import dotenv from "dotenv";
dotenv.config();
import fs from "fs";
import { google } from "googleapis";
import { JSDOM } from "jsdom";

async function main() {
  const credentials = JSON.parse(
    fs.readFileSync(process.env.TEST_CYPRESS_GMAIL_CRED as string, "utf-8")
  );

  console.log(credentials);
  const auth = new google.auth.OAuth2(
    credentials.web.client_id,
    credentials.web.client_secret,
    process.env.TEST_CYPRESS_GMAIL_API_REDIRECT_URI as string
  );
  auth.setCredentials({
    access_token: process.env.TEST_CYPRESS_GMAIL_ACCESS_TOKE as string,
    refresh_token: process.env.TEST_CYPRESS_GMAIL_REFRESH_TOKEN as string,
  });

  const gmail = google.gmail({ version: "v1", auth });
  const res = await gmail.users.messages.list({
    userId: "me",
    maxResults: 10,
  });
  const messages = res.data.messages;
  for (let message of messages!) {
    try {
      const msg = await gmail.users.messages.get({
        userId: "me",
        id: message.id!,
      });
      const data = JSON.stringify(msg.data.payload?.body?.data);
      const mailBody = Buffer.from(data, "base64").toString();
      const dom = new JSDOM(mailBody);
      const idx = process.env.NEXT_PUBLIC_ENV_NAME === "local" ? 1 : 0;
      const link = dom.window.document.querySelectorAll("p")[idx].textContent;
      console.log(link);
      return link;
    } catch (e) {
      console.log(e);
    }
  }
}

main();
