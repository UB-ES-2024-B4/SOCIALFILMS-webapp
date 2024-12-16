describe('ReviewCard Like/Dislike Functionality', () => {
    const baseUrl = Cypress.env('URL');
    const movieId = 402431;
    context('When user is not logged in', () => {
      it('should display like and dislike buttons as inactive', () => {
        cy.visit(`${baseUrl}/movies/${movieId}`);
        cy.get('button[aria-label="Like"]').should('exist').and('not.have.class', 'active');
        cy.get('button[aria-label="Dislike"]').should('exist').and('not.have.class', 'active');
      });
  
      it('should not allow liking or disliking if not logged in', () => {
        cy.visit(`${baseUrl}/movies/${movieId}`);
        // Verify that no action is triggered by checking that the button is disabled
        cy.get('button[aria-label="Like"]').eq(0).should('be.disabled');
        
        cy.get('button[aria-label="Dislike"]').eq(0).should('be.disabled');
      });
  
    });
  
    context('When user is logged in', () => {
      
      it('should add a like when like button is clicked', () => {
        cy.login();
        cy.visit(`${baseUrl}/movies/${movieId}`);
        cy.wait(3000);
        // Ensure the "Like" button is in the unliked state
        cy.get('button[aria-label="Like"]')
        .eq(0)
        .find('.p-button-icon')
        .then((icon) => {
            if (icon.hasClass('pi-thumbs-up-fill')) {
            // If the button is in the liked state, click it to unlike
            cy.get('button[aria-label="Like"]').eq(0).click();
            cy.log('Like button is in the liked state. Clicking to unlike it.');
            cy.wait(1000);
            } else {
            cy.log('Like button is already in the unliked state.');
            }
        });

        // Get the initial likes count
        cy.get('button[aria-label="Like"]')
        .eq(0)
        .parent('span')
        .invoke('text')
        .then((initialText) => {
          const initialLikes = parseInt(initialText.trim()) || 0;
          cy.log(`Initial likes: ${initialLikes}`);
          cy.wait(3000);
          // Click the like button
          cy.get('button[aria-label="Like"]').eq(0).click();
          cy.wait(3000);
          // Wait and assert the likes count is incremented
          cy.get('button[aria-label="Like"]')
            .eq(0)
            .parent('span')
            .then(($span) => {
              const updatedLikes = parseInt($span.text().trim());
              cy.log(`Updated likes: ${updatedLikes}`);
              expect(updatedLikes).to.equal(initialLikes + 1);
            });
        });

        // return to initial state
        cy.get('button[aria-label="Like"]').eq(0).click();
        cy.wait(1000);
        
      });
  
      
  
      it('should add a dislike when dislike button is clicked', () => {
        cy.login();
        cy.visit(`${baseUrl}/movies/${movieId}`, { failOnStatusCode: false });
        cy.wait(3000);
        // Ensure the "Dislike" button is in the undisliked state
        cy.get('button[aria-label="Dislike"]')
        .eq(0)
        .find('.p-button-icon')
        .then((icon) => {
            if (icon.hasClass('pi-thumbs-down-fill')) {
              // If the button is in the disliked state, click it to undisliked
              cy.get('button[aria-label="Dislike"]').eq(0).click();
              cy.log('Dislike button is in the disliked state. Clicking to undisliked it.');
              cy.wait(3000);
            } else {
              cy.log('Dislike button is already in the undisliked state.');
            }
        });
        // Get the initial Dislikes count
        cy.get('button[aria-label="Dislike"]')
        .eq(0)
        .parent('span')
        .invoke('text')
        .then((initialText) => {
          const initialDislikes = parseInt(initialText.trim()) || 0;
          cy.log(`Initial Dislikes: ${initialDislikes}`);
          cy.wait(3000);
          // Click the Dislike button
          cy.get('button[aria-label="Dislike"]').eq(0).click();
          cy.wait(3000);
          // Wait and assert the Dislikes count is incremented
          cy.get('button[aria-label="Dislike"]')
            .eq(0)
            .parent('span')
            .then(($span) => {
              const updatedDislikes = parseInt($span.text().trim());
              cy.log(`Updated Dislikes: ${updatedDislikes}`);
              expect(updatedDislikes).to.equal(initialDislikes + 1);
            });
        });
        // return to initial state
        cy.get('button[aria-label="Dislike"]').eq(0).click();
        cy.wait(1000);
      });
  
      it('should switch from like to dislike when dislike button is clicked', () => {
        cy.login();
        cy.visit(`${baseUrl}/movies/${movieId}`);
        cy.wait(3000);
        // Click the like button and verify it becomes active
        cy.get('button[aria-label="Like"]').eq(0).click({ force: true });
        cy.wait(1000);
        // Verify that the like icon is in the "active" state
        cy.get('button[aria-label="Like"] .p-button-icon').should('have.class', 'pi-thumbs-up-fill'); 

        // Click the dislike button and verify the state switches
        cy.get('button[aria-label="Dislike"]').eq(0).click();
        cy.wait(1000);
        // Verify that the like button is no longer in the "active" state
        cy.get('button[aria-label="Like"] .p-button-icon').should('have.class', 'pi-thumbs-up');  
        // Verify that the dislike button icon changes to the active state (assuming there is a similar class for it)
        cy.get('button[aria-label="Dislike"] .p-button-icon').should('have.class', 'pi-thumbs-down-fill'); 

        // return to initial state
        cy.get('button[aria-label="Dislike"]').eq(0).click();
        cy.wait(1000);
      });
  
      it('should remove like when like button is clicked again', () => {
        cy.login();
        cy.visit(`${baseUrl}/movies/${movieId}`);
        cy.wait(3000);
        cy.get('button[aria-label="Like"]').eq(0).click();
        cy.wait(1000);
        cy.get('button[aria-label="Like"]').eq(0).click();
        // Verify that the like button is no longer in the "active" state
        cy.get('button[aria-label="Like"] .p-button-icon').should('have.class', 'pi-thumbs-up');  // Assert that the unfilled thumbs-up icon is present
      });

      it('should be able to handle spamming like button', () => {
        cy.login();
        cy.visit(`${baseUrl}/movies/${movieId}`);
        cy.wait(3000);
        // Ensure the "Like" button is in the unliked state
        cy.get('button[aria-label="Like"]')
        .eq(0)
        .find('.p-button-icon')
        .then((icon) => {
            if (icon.hasClass('pi-thumbs-up-fill')) {
            // If the button is in the liked state, click it to unlike
            cy.wait(1000);
            cy.get('button[aria-label="Like"]').eq(0).click();
            cy.log('Like button is in the liked state. Clicking to unlike it.');
            cy.wait(1000);
            } else {
            cy.log('Like button is already in the unliked state.');
            }
        });
        // Get the initial likes count
        cy.get('button[aria-label="Like"]')
          .eq(0)
          .parent('span')
          .invoke('text')
          .then((initialText) => {
            const initialLikes = parseInt(initialText.trim()) || 0;
            cy.log(`Initial likes: ${initialLikes}`);
      
            // Spam-click the like button multiple times
            for (let i = 0; i < 11; i++) {
              cy.wait(500);
              cy.get('button[aria-label="Like"]').eq(0).click();
            }
      
            // Wait for any asynchronous updates (if needed)
            cy.wait(3000);
      
            // Assert that the likes count has increased by only 1
            cy.get('button[aria-label="Like"]')
              .eq(0)
              .parent('span')
              .invoke('text')
              .then((updatedText) => {
                const updatedLikes = parseInt(updatedText.trim()) || 0;
                cy.log(`Updated likes: ${updatedLikes}`);
                expect(updatedLikes).to.equal(initialLikes + 1);
              });
          });
        // return to initial state
        cy.get('button[aria-label="Like"]').eq(0).click();
        cy.wait(1000);
      });
      

    });
  });