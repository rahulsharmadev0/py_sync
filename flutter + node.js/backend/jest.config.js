module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testMatch: ["**/__tests__/**/*.ts?(x)", "**/?(*.)+(spec|test).ts?(x)"],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  coveragePathIgnorePatterns: ["/node_modules/"],
  verbose: true,
  testTimeout: 10000, // 10 seconds timeout for tests
  setupFilesAfterEnv: ["./jest.setup.js"],
};
