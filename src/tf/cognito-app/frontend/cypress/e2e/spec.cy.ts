describe("Basic template spec for cognito app frontend", () => {
  it("enter home page", () => {
    cy.visit(Cypress.env("base_url"))
      .get('[data-testid="icon-login-btn"]')
      .click();
  });
});
