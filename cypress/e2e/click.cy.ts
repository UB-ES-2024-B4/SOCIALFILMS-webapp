describe('template spec', () => {
  it('clicks the link "type"', () => {
    cy.visit('https://socialfilms.nuxt.dev/')
    cy.contains('Inicia sessió').click()
    cy.url().should('include', '/login')
  })
})