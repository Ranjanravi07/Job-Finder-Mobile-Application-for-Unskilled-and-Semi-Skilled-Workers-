function normalizePhone(phone) {
  let normalized = phone.replace(/[^\d+]/g, '');
  if (normalized.startsWith('+977')) return normalized;
  if (normalized.length === 10 && (normalized.startsWith('98') || normalized.startsWith('97'))) {
    return `+977${normalized}`;
  }
  return normalized;
}

function isValidNepalPhone(phone) {
  const normalized = normalizePhone(phone);
  const regex = /^\+977(98|97)\d{8}$/;
  return regex.test(normalized);
}

module.exports = { normalizePhone, isValidNepalPhone };
