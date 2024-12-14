describe('Login functionality', () => {
  const baseUrl = Cypress.env('URL');

  it('Navega a la pagina de login', () => {
    cy.visit(baseUrl);
    cy.wait(4000);
    cy.contains('Inicia sessió').click(); 
    cy.wait(2000);
    cy.url().should('include', '/login'); 
  });

  it('Inicia sesión con credenciales validas', () => {
    cy.visit(baseUrl);
    cy.wait(2000);
    cy.contains('Inicia sessió').click(); 
    cy.wait(2000);
    cy.url().should('include', '/login');

    
    cy.get('input[id="on_label_email"]').type('marclosquino2@gmail.com'); 
    cy.get('#on_label_password').type('Amen1+');

    
    cy.get('button[type="submit"]').click();

    
    cy.url().should('include', '/');
  });

  it('Muestra error para credenciales invalidas', () => {
    cy.visit(baseUrl);
    cy.wait(2000);
    cy.contains('Inicia sessió').click(); 
    cy.wait(2000);
    cy.url().should('include', '/login');

    
    cy.get('input[id="on_label_email"]').type('fakeemail@example.com'); 
    cy.get('#on_label_password').type('Amen1+');

    
    cy.get('button[type="submit"]').click();

    
    cy.contains('Credencials invàlides').should('be.visible');
  });
});
