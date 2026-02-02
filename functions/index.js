const { beforeUserCreated, beforeUserSignedIn } = require('firebase-functions/v2/identity');

exports.beforecreated = beforeUserCreated((event) => {
  console.log('beforecreated triggered for:', event.data.uid);
  return {
    customClaims: {
      role: 'authenticated',
    },
  };
});

exports.beforesignedin = beforeUserSignedIn((event) => {
  console.log('beforesignedin triggered for:', event.data.uid);
  return {
    customClaims: {
      role: 'authenticated',
    },
  };
});
