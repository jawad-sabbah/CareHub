export const validateRegisterData = (data) => {
  const {
    fullName,
    email,
    phone_number,
    date_of_birth,
    gender,
    password,
  } = data;

  if (!fullName || !email || !phone_number || !date_of_birth || !gender || !password) {
    throw new Error("All fields are required");
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error("Invalid email format");
  }

  if (!/^\d{8}$/.test(phone_number)) {
    throw new Error("Phone number must be 8 digits");
  }

  if (!["M", "F"].includes(gender)) {
    throw new Error("Gender must be M or F");
  }

  if (password.length < 6) {
    throw new Error("Password must be at least 6 characters");
  }

  if (isNaN(new Date(date_of_birth).getTime())) {
    throw new Error("Invalid date of birth format");
  }
};