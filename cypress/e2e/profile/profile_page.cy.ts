describe('Profile Page Functionality', () => {
  const baseUrl = Cypress.env('URL');
  const username = 'testuser';
  const movieId = 123;

  beforeEach(() => {
    cy.visit(`${baseUrl}/profile/${username}`);

    cy.url().then((currentUrl) => {
      if (currentUrl.includes('/login')) {
        cy.wait(2000);
        cy.get('input[id="on_label_email"]')
          .should('be.visible')
          .clear()
          .type('testuser2@test.com', { delay: 100 });

          cy.get('#on_label_password')
            .should('be.visible')
            .clear()
            .type('Test_12', { delay: 100 });
        cy.get('button[type="submit"]').click();
        cy.wait(2000);
        cy.visit(`${baseUrl}/profile/${username}`);
        cy.wait(2000);
      }
    });
  });

  it('Muestra correctamente los elementos básicos del perfil', () => {
    cy.get('img[alt="Profile"]')
      .should('be.visible')
      .and('have.attr', 'src')
      .and('include', 'profile_picture_maker_before.webp');

    cy.get('h1').should('have.class', 'font-extrabold').and('be.visible');
    cy.get('h3').should('have.class', 'text-gray-500').and('be.visible');

    cy.contains('seguidores').should('be.visible');
    cy.contains('siguiendo').should('be.visible');

    cy.contains('Seguir').should('be.visible');
    cy.contains('Compartir perfil').should('be.visible');
  });

  it('Muestra información "Sobre mí" o mensaje predeterminado', () => {
    cy.get('h2').contains('Sobre mí').should('be.visible');

    cy.get('p').then(($bio) => {
      if ($bio.text().includes('Este usuario aún no ha escrito nada sobre sí mismo.')) {
        cy.contains('Este usuario aún no ha escrito nada sobre sí mismo.').should('be.visible');
      } else {
        cy.get('p.text-lg.text-justify').should('be.visible');
      }
    });
  });

  it('Muestra películas favoritas o mensaje predeterminado', () => {
    cy.get('h2').contains('Películas favoritas').should('be.visible');
  });

  it('Muestra reseñas o mensaje predeterminado', () => {
    cy.get('h2').contains(/\d+ Reseñas/).should('be.visible');
  });

  // it('Permite usar el botón de seguir', () => {
  //   cy.contains('Seguir').click();
  //   cy.contains('Siguiendo').should('be.visible');
  // });

  it('Sigue y deja de seguir a un usuario', () => {
    cy.contains('Seguir').click();
    cy.wait(500);
    cy.contains('Siguiendo').should('be.visible');
    cy.wait(500);
    cy.contains('Seguiendo').click();
    cy.wait(500);
    cy.contains('Seguir').should('be.visible');
  });

  it('Permite compartir el perfil', () => {
    cy.window().then((win) => {
      cy.stub(win.navigator.clipboard, 'writeText').resolves();
    });

    // Hacer clic en el botón de compartir
    cy.contains('Compartir perfil').click();

    // Validar que el toast de éxito aparece
    cy.contains('El enlace se ha copiado al portapapeles.').should('be.visible');
  });
});