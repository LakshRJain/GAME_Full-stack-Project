// eslint.config.js
import js from "@eslint/js";

export default [
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        console: "readonly",
        process: "readonly",
        module: "readonly",
        require: "readonly",
        __dirname: "readonly",
      },
    },
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off",
      "no-undef": "off",
    },
  },
];
