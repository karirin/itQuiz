module.exports = [
  {
    files: ["**/*.js"],
    ignores: ["node_modules/**"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        console: "readonly",
        exports: "writable",
        module: "writable",
        require: "readonly",
        process: "readonly",
        __dirname: "readonly",
      },
    },
    rules: {
      "no-undef": "error",
      "no-unused-vars": ["error", {argsIgnorePattern: "^_"}],
    },
  },
];
