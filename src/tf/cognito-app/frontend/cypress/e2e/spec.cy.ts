describe("Basic template spec for cognito app frontend", () => {
  it("enter home page", () => {
    cy.visit("/")
      .clearAllLocalStorage()
      .get('[data-testid="icon-login-btn"]')
      .click()
      .get('[data-testid="login-email-input"]')
      .focus()
      .type(Cypress.env("test_email"))
      .get('[data-testid="login-email-submit-btn"]')
      .click()
      .wait(10000)
      .task("gmail:check")
      .then((email) => {
        cy.visit((email as string).replace(Cypress.env("baseUrl"), ""))
          .location("pathname")
          .should("eq", "/");
      })
      .wait(2000)
      .get('[data-testid="icon-login-btn"]')
      .click()
      .get('[data-testid="logout-link"]')
      .click()
      .location("pathname")
      .should("eq", "/logout");
  });
});
