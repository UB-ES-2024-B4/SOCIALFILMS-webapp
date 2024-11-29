describe('Publish and delete review functionality', () => {
    const baseUrl = 'https://socialfilms.nuxt.dev/';
    const email = 'marclosquino2@gmail.com';
    const password = 'Amen1+';
    let userId = '062cd767-f3fa-4bcf-9bee-230062f19fb0'; 
    let movieId = 402431; 
    let reviewId; 

    beforeEach(() => {
        cy.request({
            method: 'POST',
            url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/get_reviews',
            headers: {
                'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
            },
            body: {
                _user_id: userId,
                _movie_id: movieId,
            },
            failOnStatusCode: false, 
        }).then((response) => {
            expect(response.status).to.be.oneOf([200, 204]); 

            const reviews = response.body || []; 
            if (reviews.length > 0) {
                reviewId = reviews[0].id;
                cy.request({
                    method: 'POST',
                    url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/delete_review',
                    headers: {
                        'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                        'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
                    },
                    body: {
                        _review_id: reviewId,
                    },
                }).then((deleteResponse) => {
                    expect(deleteResponse.status).to.eq(204); 
                });
            }
        });
    });

    it('Does not allow to publish a review', () => {
        cy.visit(`${baseUrl}movies/${movieId}`);
        cy.wait(2000);
        cy.contains('Añadir review').click();
        cy.wait(2000);
        cy.get('textarea').type('Muy buena pelicula');
        cy.contains('Publicar').click();
        cy.get('.p-toast-detail') 
            .should('contain.text', 'Debes estar logueado para dejar una reseña'); 
    });
  
    it('Publishes and deletes a review', () => {
        cy.visit(baseUrl);
        cy.contains('Inicia sessió').click();
        cy.get('input[id="on_label_email"]').type(email);
        cy.get('#on_label_password').type(password);
        cy.get('button[type="submit"]').click();
        cy.wait(1000);
        cy.url().should('include', '/');
  
        cy.wait(1000);
        cy.visit(`${baseUrl}movies/${movieId}`);
        cy.wait(2000);
        cy.contains('Añadir review').click();
        cy.wait(2000);
        cy.get('textarea').type('Muy buena pelicula');
        cy.contains('Publicar').click();
        cy.get('.p-toast-detail')
            .should('contain.text', 'Tu reseña se ha publicado con éxito.');
  
        cy.request({
            method: 'POST',
            url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/get_reviews',
            headers: {
                'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
            },
            body: {
                _user_id: userId,
                _movie_id: movieId,
            },
        }).then((response) => {
            expect(response.status).to.eq(200);
            const reviews = response.body || []; 
            expect(reviews).to.have.length.above(0); 
            reviewId = reviews[0].id; 
  
            cy.request({
                method: 'POST',
                url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/delete_review',
                headers: {
                    'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                    'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
                },
                body: {
                    _review_id: reviewId,
                },
            }).then((deleteResponse) => {
                expect(deleteResponse.status).to.eq(204);
            });
        });
    });

    it('Publishes a review with spoilers', () => {
        cy.visit(baseUrl);
        cy.contains('Inicia sessió').click();
        cy.get('input[id="on_label_email"]').type(email);
        cy.get('#on_label_password').type(password);
        cy.get('button[type="submit"]').click();
        cy.url().should('include', '/');

        cy.visit(`${baseUrl}movies/${movieId}`);
        cy.wait(2000);
        cy.contains('Añadir review').click();
        cy.wait(2000);
        cy.get('textarea').type('Muy buena pelicula');
        cy.get('input[type="checkbox"]').check();
        cy.contains('Publicar').click();
        cy.get('.p-toast-detail') 
            .should('contain.text', 'Tu reseña se ha publicado con éxito.');
        cy.visit(`${baseUrl}movies/${movieId}`);
        cy.contains('Marc') 
            .should('exist') 
            .parent()
            .parent()
            .parent()
            .parent() 
            .within(() => {
                cy.contains(' ⚠️ Esta review contiene spoilers! ').should('exist'); 
                cy.contains('Mostrar').click(); 
                cy.contains('Muy buena pelicula').should('be.visible');
            });
        
        cy.request({
            method: 'POST',
            url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/get_reviews',
            headers: {
                'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
            },
            body: {
                _user_id: userId,
                _movie_id: movieId,
            },
        }).then((response) => {
            expect(response.status).to.eq(200);
            const reviews = response.body || []; 
            expect(reviews).to.have.length.above(0); 
            reviewId = reviews[0].id; 
  
            cy.request({
                method: 'POST',
                url: 'https://jxbspkcbkgmtnrvylrqa.supabase.co/rest/v1/rpc/delete_review',
                headers: {
                    'apikey': Cypress.env('SUPABASE_SERVICE_KEY'),
                    'Authorization': `Bearer ${Cypress.env('SUPABASE_SERVICE_KEY')}`,
                },
                body: {
                    _review_id: reviewId,
                },
            }).then((deleteResponse) => {
                expect(deleteResponse.status).to.eq(204);
            });
        });
    });
});
