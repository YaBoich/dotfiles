-- Cookie setup:
-- Inspect profile element, go to Storage/Application tab
-- Search "LEETCODE_SESSION"
-- Search "csrftoken"

vim.keymap.set("n", "<leader>ll", "<cmd>LBQuestions<CR>")       -- l > List questions
vim.keymap.set("n", "<leader>lq", "<cmd>LBQuestion<CR>")        -- q > View question
vim.keymap.set("n", "<leader>lr", "<cmd>LBReset<CR>")           -- r > Reset Code
vim.keymap.set("n", "<leader>lt", "<cmd>LBTest<CR>")            -- t > Test / Run Code
vim.keymap.set("n", "<leader>ls", "<cmd>LBSubmit<CR>")          -- s > Submit Code
vim.keymap.set("n", "<leader>lc", "<cmd>LBChangeLanguage<CR>")  -- c > Change language

