// simple account state for the StockScope web app
const AUTH_USERS_KEY = "stockscope_users";
const AUTH_CURRENT_USER_KEY = "stockscope_current_user";

function getUsers() {
  return JSON.parse(localStorage.getItem(AUTH_USERS_KEY)) || [];
}

function saveUsers(users) {
  localStorage.setItem(AUTH_USERS_KEY, JSON.stringify(users));
}

function registerUser(name, email, password) {
  const users = getUsers();
  const normalizedEmail = email.trim().toLowerCase();

  if (users.some((user) => user.email === normalizedEmail)) {
    throw new Error("This email is already registered. Please sign in instead.");
  }

  const newUser = {
    name: name.trim(),
    email: normalizedEmail,
    password
  };

  users.push(newUser);
  saveUsers(users);
  localStorage.setItem(AUTH_CURRENT_USER_KEY, JSON.stringify({
    name: newUser.name,
    email: newUser.email
  }));

  return newUser;
}

function loginUser(email, password) {
  const users = getUsers();
  const normalizedEmail = email.trim().toLowerCase();
  const user = users.find((item) => item.email === normalizedEmail && item.password === password);

  if (!user) {
    throw new Error("No account found with this email and password.");
  }

  localStorage.setItem(AUTH_CURRENT_USER_KEY, JSON.stringify({
    name: user.name,
    email: user.email
  }));

  return user;
}

function getCurrentUser() {
  return JSON.parse(localStorage.getItem(AUTH_CURRENT_USER_KEY));
}

function logoutUser() {
  localStorage.removeItem(AUTH_CURRENT_USER_KEY);
}
