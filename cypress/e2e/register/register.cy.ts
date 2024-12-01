describe('Test de registro', () => {
    beforeEach(() => {
      
      const email = 'usuario.prueba@example.com';
      
      
      cy.request({
        method: 'POST',
        url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/delete_user_by_email',
        headers: {
          'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),  
          'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,  
        },
        body: {
            p_email: email,  
        },
      }).then((response) => {
        
        expect(response.status).to.eq(204); 
      });
  
      
      cy.visit('https://socialfilms.nuxt.dev/signup');
    });
  
    it('Debería registrar un usuario correctamente', () => {
      cy.wait(1000);
      cy.get('#on_label_username').type('UsuarioPrueba');
  
      
      cy.get('#on_label_email').type('usuario.prueba@example.com');
  
      
      cy.get('#on_label_password').type('Contraseña1+');


      cy.get('body').click(0,0); 
  
      
      cy.get('#on_label_confirm_password').type('Contraseña1+');
  
      
      cy.get('form').submit();
  
      
      cy.get('.pi-check-circle').should('be.visible');
      cy.contains("T'has registrat amb exit!").should('be.visible');
    });
  
    it('Debería mostrar error si las contraseñas no coinciden', () => {
      cy.wait(1000);
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('DiferenteContraseña');
      cy.get('form').submit();
  
      
      cy.contains('Les contrasenyes no coinxideixen').should('be.visible');
    });
  
    it('Debería mostrar error si el correo ya existe', () => {
      cy.wait(1000);
      cy.get('#on_label_email').type('marclosquino2@gmail.com');
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('Contraseña1+');
      cy.get('form').submit();
  
      
      cy.contains('El correu electrònic ya existeix').should('be.visible');
    });
  
    it('Debería mostrar error si el correo es inválido', () => {
      cy.get('#on_label_email').type('correo.invalido');
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('Contraseña1+');
      cy.get('form').submit();
  
      cy.contains('El correu electrònic no és vàlid').should('be.visible');
    });
  });
  