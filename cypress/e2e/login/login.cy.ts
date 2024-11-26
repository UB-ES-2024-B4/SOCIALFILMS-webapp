describe('Login functionality', () => {
  const baseUrl = 'https://socialfilms.nuxt.dev/';

  it('navigates to the login page', () => {
    cy.visit(baseUrl);
    cy.contains('Inicia sessió').click(); 
    cy.url().should('include', '/login'); 
  });

  it('logs in with valid credentials', () => {
    cy.visit(baseUrl);
    cy.contains('Inicia sessió').click(); 
    cy.url().should('include', '/login');

    
    cy.get('input[id="on_label_email"]').type('marclosquino2@gmail.com'); 
    cy.get('#on_label_password').type('Amen1+');

    
    cy.get('button[type="submit"]').click();

    
    cy.url().should('include', '/');
  });

  it('shows error for invalid credentials', () => {
    cy.visit(baseUrl);
    cy.contains('Inicia sessió').click(); 
    cy.url().should('include', '/login');

    
    cy.get('input[id="on_label_email"]').type('fakeemail@example.com'); 
    cy.get('#on_label_password').type('Amen1+');

    
    cy.get('button[type="submit"]').click();

    
    cy.contains('Credencials invàlides').should('be.visible');
  });
});
