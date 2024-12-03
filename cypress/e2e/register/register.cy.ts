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
  
      
      cy.visit(`${Cypress.env('URL')}/signup`);
    });
  
    it('Debería registrar un usuario correctamente', () => {
      cy.wait(2000);
      cy.get('#on_label_username').type('UsuarioPrueba');
  
      
      cy.get('#on_label_email').type('usuario.prueba@example.com');
  
      
      cy.get('#on_label_password').type('Contraseña1+');


      cy.get('body').click(0,0); 
  
      
      cy.get('#on_label_confirm_password').type('Contraseña1+');
      
      cy.contains('Següent').click();

      cy.get('#on_label_name').type('Nombre');

      cy.get('#on_label_surname').type('Apellido');

      cy.get('.p-inputtext.p-component.p-datepicker-input').click(); 
      cy.get('.p-datepicker-prev-button').click();

      cy.get('.p-datepicker-calendar td')
        .contains('11') 
        .click(); 

      cy.get('.p-select-dropdown').click();

      cy.contains('.p-select-option', 'Spain').click();

      cy.contains('Biografia').get('textarea').type('Biografia de prueba');

      cy.contains('Completar registre').click();

      cy.get('.pi-check-circle').should('be.visible');
      cy.contains("T'has registrat amb exit!").should('be.visible');
    });
  
    it('Debería mostrar error si las contraseñas no coinciden', () => {
      cy.wait(2000);
      cy.get('#on_label_username').type('UsuarioPrueba');
      cy.get('#on_label_email').type('usuario.prueba@example.com');
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('DiferenteContraseña');
      cy.contains('Les contrasenyes no coincideixen').should('be.visible');
    });
  
    it('Debería mostrar error si el correo ya existe', () => {
      cy.wait(2000);
      cy.get('#on_label_username').type('UsuarioPrueba');
      cy.get('#on_label_email').type('marclosquino2@gmail.com');
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('Contraseña1+');
      cy.contains('Següent').click();

      cy.get('#on_label_name').type('Nombre');

      cy.get('#on_label_surname').type('Apellido');

      cy.get('.p-inputtext.p-component.p-datepicker-input').click(); 
      cy.get('.p-datepicker-prev-button').click();

      cy.get('.p-datepicker-calendar td')
        .contains('11') 
        .click(); 

      cy.get('.p-select-dropdown').click();

      cy.contains('.p-select-option', 'Spain').click();

      cy.contains('Biografia').get('textarea').type('Biografia de prueba');

      cy.contains('Completar registre').click();
      
      cy.contains('El correu electrònic ya existeix').should('be.visible');
    });
  
    it('Debería mostrar error si el correo es inválido', () => {
      cy.wait(2000);
      cy.get('#on_label_username').type('UsuarioPrueba');
      cy.get('#on_label_email').type('correo.invalido');
      cy.get('#on_label_password').type('Contraseña1+');
      cy.get('body').click(0,0); 
      cy.get('#on_label_confirm_password').type('Contraseña1+');
      cy.contains('Següent').click();

      cy.get('#on_label_name').type('Nombre');

      cy.get('#on_label_surname').type('Apellido');

      cy.get('.p-inputtext.p-component.p-datepicker-input').click(); 
      cy.get('.p-datepicker-prev-button').click();

      cy.get('.p-datepicker-calendar td')
        .contains('11') 
        .click(); 

        cy.get('.p-select-dropdown').click();

      cy.contains('.p-select-option', 'Spain').click();

      cy.contains('Biografia').get('textarea').type('Biografia de prueba');

      cy.contains('Completar registre').click();
  
      cy.contains('El correu electrònic no és vàlid').should('be.visible');
    });
  });
  