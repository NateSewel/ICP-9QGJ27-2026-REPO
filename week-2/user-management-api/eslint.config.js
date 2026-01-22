module.exports = [
    {
        files: ["src/**/*.js"],
        languageOptions: {
            ecmaVersion: "latest",
            sourceType: "commonjs",
        },
        rules: {
            "no-unused-vars": "warn",
            "no-console": "off",
        },
    },
];
